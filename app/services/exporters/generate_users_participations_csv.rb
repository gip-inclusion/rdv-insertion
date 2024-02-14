module Exporters
  class GenerateUsersParticipationsCsv < GenerateUsersCsv
    private

    def each_element(&block)
      @users.each do |user|
        user.participations.joins(:rdv).where(rdv: { organisation_id: @agent.organisation_ids }).to_a.each(&block)
      end
    end

    def preload_associations
      @users =
        if @motif_category
          User.preload(:archives, :tags, :referents, :organisations)
        else
          User.preload(:invitations, :notifications, :archives, :organisations, :tags, :referents)
        end

      @users = @users.preload(
        participations: [
          :organisation,
          {
            rdv_context: [
              :invitations,
              :notifications,
              { rdvs: [:motif, :organisation, :participations, :users] }
            ]
          }
        ]
      )
      @users = @users.find(@user_ids)
    end

    def headers
      [User.human_attribute_name(:title),
       User.human_attribute_name(:last_name),
       User.human_attribute_name(:first_name),
       User.human_attribute_name(:affiliation_number),
       User.human_attribute_name(:department_internal_id),
       User.human_attribute_name(:nir),
       User.human_attribute_name(:france_travail_id),
       User.human_attribute_name(:email),
       User.human_attribute_name(:address),
       User.human_attribute_name(:phone_number),
       User.human_attribute_name(:birth_date),
       User.human_attribute_name(:created_at),
       User.human_attribute_name(:rights_opening_date),
       User.human_attribute_name(:role),
       "Date du RDV",
       "Heure du RDV",
       "Motif du RDV",
       "Nature du RDV",
       "Dernier RDV pris en autonomie ?",
       Rdv.human_attribute_name(:status),
       Archive.human_attribute_name(:created_at),
       Archive.human_attribute_name(:archiving_reason),
       User.human_attribute_name(:referents),
       "Organisation du rendez-vous",
       User.human_attribute_name(:tags)]
    end

    def csv_row(participation) # rubocop:disable Metrics/AbcSize
      user = participation.user

      [user.title,
       user.last_name,
       user.first_name,
       user.affiliation_number,
       user.department_internal_id,
       user.nir,
       user.france_travail_id,
       user.email,
       user.address,
       user.phone_number,
       display_date(user.birth_date),
       display_date(user.created_at),
       display_date(user.rights_opening_date),
       user.role,
       display_date(rdv_date(participation)),
       display_time(rdv_date(participation)),
       rdv_motif(participation),
       rdv_type(participation),
       rdv_taken_in_autonomy?(participation),
       human_status(participation),
       display_date(user.archive_for(department_id)&.created_at),
       user.archive_for(department_id)&.archiving_reason,
       user.referents.map(&:email).join(", "),
       participation.organisation.name,
       user.tags.pluck(:value).join(", ")]
    end

    def resource_human_name
      "rdvs"
    end

    def rdv_date(participation)
      participation.rdv.starts_at
    end

    def rdv_motif(participation)
      participation.rdv.motif&.name || ""
    end

    def rdv_taken_in_autonomy?(participation)
      I18n.t("boolean.#{participation.created_by_user?}")
    end

    def rdv_type(participation)
      participation.rdv.collectif? ? "collectif" : "individuel"
    end

    def human_status(participation)
      I18n.t("activerecord.attributes.rdv.statuses.#{participation.status}")
    end

    def human_rdv_context_status(participation)
      I18n.t("activerecord.attributes.rdv_context.statuses.#{participation.rdv_context.status}") +
        display_context_status_notice(participation.rdv_context)
    end
  end
end
