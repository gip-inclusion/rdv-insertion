class SendCreneauAvailabilityAlertJob < ApplicationJob
  def perform
    Department.all.each do |departement|
      departement.organisations.each do |organisation|
        unavailable_motifs =
          Invitations::VerifyOrganisationCreneauxAvailability.new(organisation_id: organisation.id).call
        next if unavailable_motifs.empty?

        deliver_email(organisation, unavailable_motifs)
        notify_on_mattermost(organisation, unavailable_motifs)
      end
    end
  end

  private

  def deliver_email(organisation, unavailable_motifs)
    OrganisationMailer.creneau_unavailable(
      organisation: organisation,
      motifs: unavailable_motifs
    ).deliver_now
  end

  def notify_on_mattermost(organisation, unavailable_motifs)
    unavailable_motifs.each do |motif|
      MattermostClient.send_to_rgpd_channel(formated_string_for_mattermost_message(organisation, motif))
    end
  end

  def formated_string_for_mattermost_message(organisation, motif)
    string = "Créneaux indisponibles pour l'organisation #{organisation.name} (Département: #{organisation.department.name})\n" \
             "#{organisation.name} (Département: #{organisation.department.name})\n" \
             " Motif : #{motif[:motif_name]}"

    string += "\n Code postaux : #{motif[:city_codes].join(', ')}" \

    string += "\n Référents : #{motif[:referent_ids].join(', ')}\n" if motif[:referent_ids].present?

    string += "\n\n"

    string
  end
end
