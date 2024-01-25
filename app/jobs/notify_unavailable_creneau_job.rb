class NotifyUnavailableCreneauJob < ApplicationJob
  def perform(organisation_id)
    result =
      Invitations::VerifyOrganisationCreneauxAvailability.call(organisation_id: organisation_id)
    return if result.unavailable_params_motifs.empty?

    # unavailable_params_motifs = [{
    #   motif_category_name: "RSA Orientation",
    #   city_code: ["75001", "75002", "75003"],
    #   referent_ids: ["1", "2", "3"]
    # },...]
    organisation = Organisation.find(organisation_id)
    deliver_email(organisation, result.unavailable_params_motifs)
    notify_on_mattermost(organisation, result.unavailable_params_motifs)
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
      " Motif : #{motif[:motif_category_name]}\n" \
      " Nombre d'invitations concernées : #{motif[:invations_counter]}\n"

    string += " Codes postaux : #{motif[:city_codes].join(', ')}\n" if motif[:city_codes].present?

    string += " Référents (rdvsp_ids) : #{motif[:referent_ids].join(', ')}\n" if motif[:referent_ids].present?

    string += " !! L'organisation n'a pas d'email configuré et n'a pas été notifiée !!\n" if organisation.email.blank?

    string
  end
end
