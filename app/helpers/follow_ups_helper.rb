module FollowUpsHelper
  def background_class_for_follow_up_status(follow_up)
    return "" if follow_up.nil?

    if follow_up.action_required_status?
      "bg-danger border-danger"
    elsif follow_up.no_upcoming_rdv_and_all_invitations_expired?
      "bg-warning border-warning"
    elsif follow_up.rdv_seen? || follow_up.closed?
      "bg-success border-success"
    else
      ""
    end
  end

  def badge_background_class(follow_up)
    return "blue-out border border-blue" if follow_up.nil?

    if follow_up.action_required_status?
      "bg-danger border-danger"
    elsif follow_up.no_upcoming_rdv_and_all_invitations_expired?
      "bg-warning border-warning"
    elsif follow_up.rdv_seen? || follow_up.closed?
      "bg-success border-success"
    else
      "blue-out border border-blue"
    end
  end

  def display_follow_up_status(follow_up)
    return "Non rattaché" if follow_up.nil?

    I18n.t("activerecord.attributes.follow_up.statuses.#{follow_up.status}") +
      display_follow_up_status_notice(follow_up)
  end

  def display_follow_up_status_notice(follow_up)
    return if follow_up.nil?

    if follow_up.no_upcoming_rdv_and_all_invitations_expired?
      " (Délai dépassé)"
    else
      ""
    end
  end

  def should_convene_for?(follow_up, configuration)
    return false unless configuration.convene_user?

    follow_up.convocable_status? ||
      follow_up.no_upcoming_rdv_and_all_invitations_expired?
  end

  def closed_follow_up_tooltip_content
    "Le statut du bénéficiaire pour cette catégorie passera en «Dossier traité» et ses invitations " \
      "seront désactivées. Il n'apparaîtra plus dans la liste de suivi de cette catégorie, mais restera " \
      "visible dans l'onglet «Tous les contacts»."
  end
end
