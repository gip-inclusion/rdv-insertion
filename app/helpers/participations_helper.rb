module ParticipationsHelper
  def human_new_status(new_status)
    if new_status == "unknown"
      # the status can only be re-set to "unknown" if the rdv is pending
      I18n.t("activerecord.attributes.rdv.unknown_statuses.pending")
    else
      I18n.t("activerecord.attributes.rdv.statuses.#{new_status}")
    end
  end

  def human_new_status_detailed(new_status)
    if new_status == "unknown"
      # the status can only be re-set to "unknown" if the rdv is pending
      I18n.t("activerecord.attributes.rdv.unknown_statuses.detailed.pending")
    else
      I18n.t("activerecord.attributes.rdv.statuses.detailed.#{new_status}")
    end
  end

  def could_notify_status_change?(participation, new_status)
    return false if participation.in_the_past?

    (participation.pending? && new_status.in?(Participation::CANCELLED_STATUSES)) ||
      (participation.cancelled? && new_status.in?(Participation::PENDING_STATUSES))
  end

  def text_class_for_participation_status(status)
    return "text-success" if status == "seen"
    return "text-light" if status == "unknown"

    "text-danger"
  end

  def button_classes_for_participation_status(participation)
    return "" if participation.follow_up.closed?

    if participation.seen?
      "text-dark-green-alt border-light-grey"
    elsif participation.revoked?
      "text-brown border-light-grey"
    elsif participation.excused?
      "text-dark-red border-light-grey"
    elsif participation.noshow?
      "text-red-bright border-light-grey"
    elsif participation.needs_status_update?
      "background-red-pale text-dark-red"
    end
  end

  def display_convocation_formats(convocation_formats)
    if convocation_formats.empty?
      "❌#{content_tag(:br)}SMS et Email non envoyés#{content_tag(:br)}❌"
    else
      convocation_formats.map { |format| format == "sms" ? "SMS 📱" : "Email 📧" }.join("\n")
    end
  end

  def participation_created_by_tooltip_content(participation)
    author_description = {
      "prescripteur" => "un prescripteur",
      "agent" => "l'agent",
      "user" => "l'usager"
    }[participation.created_by_type]

    author_details = if participation.created_by_agent?
                       author = participation.created_by
                       " #{author} (#{author.email})" if author.present?
                     end

    "Rendez-vous pris par #{author_description}#{author_details || ''}" \
      " le #{participation.created_at.strftime('%d/%m/%Y à %H:%M')}"
  end
end
