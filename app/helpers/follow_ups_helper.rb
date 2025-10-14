module FollowUpsHelper
  TABLE_CELL_CSS_CLASSES_BY_FOLLOW_UP_STATUS = {
    no_upcoming_rdv_and_all_invitations_expired: "background-orange-pale text-brown",
    invitation_pending: "background-blue-pale text-navy-blue",
    rdv_pending: "text-navy-blue",
    rdv_needs_status_update: "background-red-pale text-dark-red",
    rdv_noshow: "text-red-bright",
    rdv_revoked: "text-brown",
    rdv_excused: "text-dark-red",
    rdv_seen: "text-dark-green-alt"
  }.freeze

  BADGE_CSS_CLASSES_BY_FOLLOW_STATUS = {
    no_upcoming_rdv_and_all_invitations_expired: "background-orange-pale text-brown",
    invitation_pending: "background-blue-pale text-navy-blue",
    rdv_pending: "text-navy-blue border-light-grey",
    rdv_needs_status_update: "background-red-pale text-dark-red",
    rdv_noshow: "text-red-bright border-light-grey",
    rdv_revoked: "text-brown border-light-grey",
    rdv_excused: "text-dark-red border-light-grey",
    rdv_seen: "text-dark-green-alt border-light-grey"
  }.freeze

  def table_cell_css_classes_for_follow_up_status(follow_up)
    TABLE_CELL_CSS_CLASSES_BY_FOLLOW_UP_STATUS.each do |condition, css_class|
      return css_class if follow_up&.send(:"#{condition}?")
    end

    ""
  end

  def badge_css_classes_for_follow_up_status(follow_up)
    BADGE_CSS_CLASSES_BY_FOLLOW_STATUS.each do |condition, css_class|
      return css_class if follow_up&.send(:"#{condition}?")
    end

    "text-grey-alt border-light-grey"
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
