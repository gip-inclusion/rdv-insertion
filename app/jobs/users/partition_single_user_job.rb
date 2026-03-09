module Users
  class PartitionSingleUserJob < ApplicationJob
    LOG_PREFIX = "[PartitionSingleUserJob]".freeze

    def perform(user_id)
      @user = User.find(user_id)

      return handle_no_department if @user.departments.none?
      return handle_single_department if @user.departments.one?

      handle_multiple_departments
    end

    private

    def handle_no_department
      skip_with_warning("#{LOG_PREFIX} usager #{@user.id} ignoré : aucun département associé")
    end

    def handle_single_department
      @user.update_column(:department_id, @user.departments.first.id)
      Rails.logger.info("#{LOG_PREFIX} ✅ usager #{@user.id} assigné au département #{@user.departments.first.number}")
    end

    # rubocop:disable Metrics/AbcSize
    def handle_multiple_departments
      Rails.logger.info(
        "#{LOG_PREFIX} 🔍 usager #{@user.id} dans les départements " \
        "#{@user.departments.map(&:number).join(', ')}, principal : #{primary_department.number}"
      )

      if upcoming_rdv_in_secondary_orgs?
        skip_with_warning(
          "#{LOG_PREFIX} usager #{@user.id} ignoré : rdv à venir dans les orgas secondaires " \
          "#{secondary_organisations.map(&:id)} (depts #{secondary_organisations.map do |o|
            o.department.number
          end.uniq.join(', ')})"
        )
        return
      end

      PaperTrail.request(whodunnit: self.class.name) { remove_from_secondary_organisations }
      @user.update_column(:department_id, primary_department.id)
      notify(
        "✅ #{LOG_PREFIX} usager #{@user.id} partitionné vers le département #{primary_department.number}, " \
        "retiré des orgas #{secondary_organisations.map(&:id)}"
      )
    end
    # rubocop:enable Metrics/AbcSize

    def primary_department
      @primary_department ||= department_from_activity(most_recent_activity)
    end

    def secondary_organisations
      @secondary_organisations ||= @user.organisations.reject { |o| o.department_id == primary_department.id }
    end

    def most_recent_activity
      [
        UsersOrganisation.where(user: @user).order(created_at: :desc).first,
        Participation.where(user: @user).order(created_at: :desc).first,
        Invitation.where(user: @user).order(created_at: :desc).first
      ].compact.max_by(&:created_at)
    end

    def department_from_activity(activity)
      case activity
      when UsersOrganisation then activity.organisation.department
      when Participation then activity.rdv.organisation.department
      when Invitation then Department.find(activity.department_id)
      end
    end

    def upcoming_rdv_in_secondary_orgs?
      Rdv.not_cancelled
         .future
         .joins(:participations, :organisation)
         .exists?(participations: { user: @user }, organisations: { id: secondary_organisations })
    end

    def remove_from_secondary_organisations
      secondary_organisations.each do |org|
        Rails.logger.info("#{LOG_PREFIX} 🗑️  usager #{@user.id} retiré de l'orga #{org.id} (#{org.name})")
        call_service!(Users::RemoveFromOrganisation, user: @user, organisation: org)
      end
    end

    def skip_with_warning(message)
      Rails.logger.warn(message)
      SlackClient.send_to_private_channel("⚠️ #{message}")
      Sentry.capture_message(message, level: :warning, extra: { user_id: @user.id })
    end

    def notify(message)
      Rails.logger.info(message)
      SlackClient.send_to_private_channel(message)
    end
  end
end
