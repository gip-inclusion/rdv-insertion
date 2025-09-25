module FollowUpsHelper
  BACKGROUND_CLASSES = {
    no_upcoming_rdv_and_all_invitations_expired?: "invitation-pending-and-expired",
    invitation_pending?: "invitation-pending",
    rdv_pending?: "rdv-pending",
    rdv_needs_status_update?: "rdv-needs-status-update",
    rdv_noshow?: "rdv-noshow",
    rdv_revoked?: "rdv-revoked",
    rdv_excused?: "rdv-excused",
    rdv_seen?: "rdv-seen"
  }.freeze

  BADGE_CLASSES = {
    no_upcoming_rdv_and_all_invitations_expired?: "invitation-pending-and-expired",
    invitation_pending?: "invitation-pending",
    rdv_pending?: "rdv-pending border-light-grey",
    rdv_needs_status_update?: "rdv-needs-status-update",
    rdv_noshow?: "rdv-noshow border-light-grey",
    rdv_revoked?: "rdv-revoked border-light-grey",
    rdv_excused?: "rdv-excused border-light-grey",
    rdv_seen?: "rdv-seen border-light-grey"
  }.freeze

  def background_class_for_follow_up_status(follow_up)
    BACKGROUND_CLASSES.each do |condition, css_class|
      return css_class if follow_up&.send(condition)
    end

    ""
  end

  def badge_background_class(follow_up)
    BADGE_CLASSES.each do |condition, css_class|
      return css_class if follow_up&.send(condition)
    end

    "uninvited-or-closed border-light-grey"
  end

  def display_follow_up_status(follow_up)
    return "Non rattaché" if follow_up.nil?

    if follow_up&.no_upcoming_rdv_and_all_invitations_expired?
      "Invitation sans réponse (délai dépassé)"
    elsif follow_up&.rdv_excused?
      "RDV annulé par l'usager (excusé)"
    else
      I18n.t("activerecord.attributes.follow_up.statuses.#{follow_up.status}")
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
