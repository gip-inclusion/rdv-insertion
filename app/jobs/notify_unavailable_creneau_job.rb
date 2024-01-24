class NotifyUnavailableCreneauJob < ApplicationJob
  def perform(organisation_id)
    unavailable_params_motifs =
      Invitations::VerifyOrganisationCreneauxAvailability.new(organisation_id: organisation_id).call
    return if unavailable_params_motifs.empty?

    # unavailable_params_motifs = [{
    #   motif_category_name: "RSA Orientation",
    #   city_code: ["75001", "75002", "75003"],
    #   referent_ids: ["1", "2", "3"]
    # },...]
    organisation = Organisation.find(organisation_id)
    deliver_email(organisation, unavailable_params_motifs)
    notify_on_mattermost(organisation, unavailable_params_motifs)
  end

  private

  def deliver_email(organisation, unavailable_params_motifs)
    OrganisationMailer.creneau_unavailable(
      organisation: organisation,
      motifs: unavailable_params_motifs
    ).deliver_now
  end

  def notify_on_mattermost(organisation, unavailable_params_motifs)
    unavailable_params_motifs.each do |motif|
      MattermostClient.send_to_notif_channel(formated_string_for_mattermost_message(organisation, motif))
    end
  end

  def formated_string_for_mattermost_message(organisation, motif)
    string =
      "Créneaux indisponibles pour l'organisation #{organisation.name}" \
      " (Département: #{organisation.department.name})\n" \
      " Motif : #{motif[:motif_category_name]}"

    string += "\n Code postaux : #{motif[:city_codes].join(', ')}" \

    string += "\n Référents (rdvsp_ids) : #{motif[:referent_ids].join(', ')}\n" if motif[:referent_ids].present?

    string += "L'organisation n'a pas d'email configuré et n'a pas été notifiée !\n" if organisation.email.blank?

    string += "\n\n"

    string
  end
end
