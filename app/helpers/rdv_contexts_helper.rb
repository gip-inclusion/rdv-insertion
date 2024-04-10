module RdvContextsHelper
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

  def badge_background_class(context, number_of_days_before_action_required)
    return "blue-out border border-blue" if context.nil?

    if context.action_required_status?
      "bg-danger border-danger"
    elsif number_of_days_before_action_required &&
          context.time_to_accept_invitation_exceeded?(number_of_days_before_action_required)
      "bg-warning border-warning"
    elsif context.rdv_seen? || context.closed?
      "bg-success border-success"
    else
      "blue-out border border-blue"
    end
  end

  def display_context_status(context, number_of_days_before_action_required)
    return "Non rattaché" if context.nil?

    I18n.t("activerecord.attributes.rdv_context.statuses.#{context.status}") +
      display_context_status_notice(context, number_of_days_before_action_required)
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

  def should_convene_for?(rdv_context, configuration)
    return false unless configuration.convene_user?

    rdv_context.convocable_status? ||
      rdv_context.time_to_accept_invitation_exceeded?(configuration.number_of_days_before_action_required)
  end
end
