class CreneauOpeningRequestMailer < ApplicationMailer
  def request_more_creneaux(creneau_opening_request:)
    @creneau_opening_request = creneau_opening_request
    @recipient_agent = creneau_opening_request.recipient_agent
    @sender_agent = creneau_opening_request.sender_agent
    @motif_category = creneau_opening_request.motif_category
    @user_list_upload = creneau_opening_request.user_list_upload

    mail(
      to: @recipient_agent.email,
      subject: "[Demande de créneaux] - Besoin de nouveaux créneaux sur la catégorie #{@motif_category.name}",
      reply_to: "rdv-insertion@inclusion.gouv.fr"
    )
  end
end
