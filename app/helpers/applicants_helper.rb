# rubocop:disable Metrics/ModuleLength

module ApplicantsHelper
  def format_date(date)
    date&.strftime("%d/%m/%Y")
  end

  def show_convocation?(configuration)
    configuration.convene_applicant?
  end

  def show_invitations?(configuration)
    configuration.invitation_formats.present?
  end

  def show_last_invitation_date?(rdv_context)
    rdv_context.present? && rdv_context.invitations.length > 1 &&
      format_date(rdv_context.last_invitation_sent_at) != format_date(rdv_context.first_invitation_sent_at)
  end

  def display_attribute(attribute)
    attribute.presence || " - "
  end

  def no_search_results?(applicants)
    applicants.empty? && params[:search_query].present?
  end

  def display_back_to_list_button?
    [
      params[:search_query], params[:status], params[:action_required], params[:first_invitation_date_before],
      params[:last_invitation_date_before], params[:first_invitation_date_after], params[:last_invitation_date_after]
    ].any?(&:present?)
  end

  def options_for_select_status(statuses_count)
    ordered_statuses_count(statuses_count).map do |status, count|
      next if count.nil?

      ["#{I18n.t("activerecord.attributes.rdv_context.statuses.#{status}")} (#{count})", status]
    end.compact
  end

  def ordered_statuses_count(statuses_count)
    [
      ["not_invited", statuses_count["not_invited"]],
      ["invitation_pending", statuses_count["invitation_pending"]],
      ["rdv_pending", statuses_count["rdv_pending"]],
      ["rdv_needs_status_update", statuses_count["rdv_needs_status_update"]],
      ["rdv_excused", statuses_count["rdv_excused"]],
      ["rdv_revoked", statuses_count["rdv_revoked"]],
      ["multiple_rdvs_cancelled", statuses_count["multiple_rdvs_cancelled"]],
      ["rdv_noshow", statuses_count["rdv_noshow"]],
      ["rdv_seen", statuses_count["rdv_seen"]]
    ]
  end

  def background_class_for_context_status(context, number_of_days_before_action_required)
    return "" if context.nil?

    if context.action_required?(number_of_days_before_action_required)
      context.attention_needed? ? "bg-warning border-warning" : "bg-danger border-danger"
    elsif context.rdv_seen?
      "bg-success border-success"
    else
      ""
    end
  end

  def background_class_for_rdv_status(rdv)
    if rdv.seen?
      "bg-success border-success"
    elsif rdv.cancelled?
      "bg-danger border-danger"
    elsif rdv.needs_status_update?
      "bg-warning border-warning"
    else
      ""
    end
  end

  def display_context_status(context, number_of_days_before_action_required)
    return "Non rattaché" if context.nil?

    I18n.t("activerecord.attributes.rdv_context.statuses.#{context.status}") +
      display_context_status_notice(context, number_of_days_before_action_required)
  end

  def display_rdv_status(rdv)
    rdv.pending? ? "À venir" : I18n.t("activerecord.attributes.rdv.statuses.#{rdv.status}")
  end

  def display_context_status_notice(context, number_of_days_before_action_required)
    return if context.nil?

    if context.invited_before_time_window?(number_of_days_before_action_required) && context.invitation_pending?
      " (Délai dépassé)"
    else
      ""
    end
  end

  def rdv_solidarites_user_url(organisation, applicant)
    organisation_id = organisation.rdv_solidarites_organisation_id
    "#{ENV['RDV_SOLIDARITES_URL']}/admin/organisations/#{organisation_id}/users/#{applicant.rdv_solidarites_user_id}"
  end

  def display_convocation_formats(convocation_formats)
    if convocation_formats.empty?
      "❌#{content_tag(:br)}SMS et Email non envoyés#{content_tag(:br)}❌"
    else
      convocation_formats.map { |format| format == "sms" ? "SMS 📱" : "Email 📧" }.join("\n")
    end
  end

  def archived_scope?(scope)
    scope == "archived"
  end

  def department_level?
    params[:department_id].present?
  end

  def compute_index_path(organisation, department, **params)
    if department_level?
      department_applicants_path(department, **params.compact_blank)
    else
      organisation_applicants_path(organisation, **params.compact_blank)
    end
  end

  def compute_edit_path(applicant, organisation, department)
    return edit_department_applicant_path(department, applicant) if department_level?

    edit_organisation_applicant_path(organisation, applicant)
  end

  def compute_applicant_path(applicant, organisation, department)
    return department_applicant_path(department, applicant) if department_level?

    organisation_applicant_path(organisation, applicant)
  end
end

# rubocop:enable Metrics/ModuleLength
