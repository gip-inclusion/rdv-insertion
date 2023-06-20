module RdvContextsHelper
  def show_convocation?(configuration)
    configuration.convene_applicant?
  end

  def show_invitations?(configuration)
    configuration.invitation_formats.present?
  end

  def background_class_for_context_status(context, number_of_days_before_action_required)
    return "" if context.nil?

    if context.action_required_status?
      "bg-danger border-danger"
    elsif number_of_days_before_action_required &&
          context.time_to_accept_invitation_exceeded?(number_of_days_before_action_required)
      "bg-warning border-warning"
    elsif context.rdv_seen? || context.closed?
      "bg-success border-success"
    else
      ""
    end
  end

  def background_class_for_participation_status(participation)
    return "" if participation.rdv_context.closed?

    if participation.seen?
      "bg-success border-success"
    elsif participation.cancelled?
      "bg-danger border-danger"
    elsif participation.needs_status_update?
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

  def display_participation_status(participation)
    participation.pending? ? "À venir" : I18n.t("activerecord.attributes.rdv.statuses.#{participation.status}")
  end

  def display_context_status_notice(context, number_of_days_before_action_required)
    return if context.nil?

    if number_of_days_before_action_required &&
       context.time_to_accept_invitation_exceeded?(number_of_days_before_action_required)
      " (Délai dépassé)"
    else
      ""
    end
  end

  def rdv_solidarites_agent_searches_url(
    rdv_solidarites_organisation_id, rdv_solidarites_user_id, rdv_solidarites_motif_id, rdv_solidarites_service_id
  )
    params = {
      user_ids: [rdv_solidarites_user_id],
      motif_id: rdv_solidarites_motif_id,
      service_id: rdv_solidarites_service_id,
      commit: "Afficher les créneaux"
    }
    "#{ENV['RDV_SOLIDARITES_URL']}/admin/organisations/#{rdv_solidarites_organisation_id}/" \
      "agent_searches?#{params.to_query}"
  end

  def should_convene_for?(rdv_context, configuration)
    return unless configuration.convene_applicant?

    rdv_context.convocable_status? ||
      rdv_context.time_to_accept_invitation_exceeded?(configuration.number_of_days_before_action_required)
  end
end
