class AlertUserAddedToAnotherDepartmentJob < ApplicationJob
  def perform(user_id, organisation_id)
    @user = User.find_by(id: user_id)
    @newly_added_organisation = Organisation.find_by(id: organisation_id)

    return if @user.nil? || @newly_added_organisation.nil?
    return unless added_to_new_department?

    alert_on_slack
    alert_on_sentry
  end

  private

  def added_to_new_department?
    existing_departments.any? &&
      existing_departments.none? { |dept| dept.id == @newly_added_organisation.department_id }
  end

  def alert_message
    @alert_message ||=
      "⚠️ L'usager #{@user.id} vient d'être ajouté à l'organisation #{@newly_added_organisation.name} " \
      "(département #{@newly_added_organisation.department.number}) alors qu'il appartient déjà " \
      "à d'autres départements: #{existing_departments.map(&:number).join(', ')}"
  end

  def existing_departments
    @existing_departments ||= @user.organisations
                                   .reject { |org| org.id == @newly_added_organisation.id }
                                   .map(&:department)
                                   .uniq
  end

  def alert_on_slack
    SlackClient.send_to_private_channel(alert_message)
  end

  def alert_on_sentry
    Sentry.capture_message(alert_message)
  end
end
