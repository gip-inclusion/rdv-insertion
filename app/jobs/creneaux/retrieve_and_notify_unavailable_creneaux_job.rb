class Creneaux::RetrieveAndNotifyUnavailableCreneauxJob < ApplicationJob
  attr_reader :organisation

  def perform(organisation_id)
    @organisation = Organisation.find(organisation_id)

    result =
      Invitations::AggregateInvitationWithoutCreneaux.call(organisation_id: organisation_id)

    @invitations_without_creneaux = result.invitations_without_creneaux

    return if @invitations_without_creneaux.empty?

    deliver_general_email
    deliver_per_category_email_to_notify_no_available_slots
    notify_on_slack
    create_blocked_invitations_counter
    create_blocked_user
  end

  private

  def invitations_without_creneaux_by_motif_category
    Invitation.includes(follow_up: :motif_category, user: :address_geocoding)
              .where(id: @invitations_without_creneaux.pluck(:id))
              .group_by(&:motif_category)
  end

  def deliver_general_email
    cache_key = "creneau_unavailable_email_#{organisation.id}_#{Date.current}"
    return if Rails.cache.exist?(cache_key)

    OrganisationMailer.creneau_unavailable(
      organisation:, invitations_without_creneaux_by_motif_category:
    ).deliver_now

    Rails.cache.write(cache_key, "email_sent", expires_in: 12.hours)
  end

  # rubocop:disable Metrics/AbcSize
  def deliver_per_category_email_to_notify_no_available_slots
    invitations_without_creneaux_by_motif_category.each do |motif_category, invitations|
      matching_category_configuration = organisation
                                        .category_configurations
                                        .find_by(motif_category_id: motif_category.id)

      next unless matching_category_configuration&.notify_no_available_slots?

      cache_key = "no_available_slots_email_#{organisation.id}_#{Date.current}_#{motif_category.id}"
      next if Rails.cache.exist?(cache_key)

      OrganisationMailer.notify_no_available_slots(
        organisation: organisation,
        invitations:,
        motif_category_name: motif_category.name,
        recipient: matching_category_configuration.email_to_notify_no_available_slots
      ).deliver_now

      Rails.cache.write(cache_key, "email_sent", expires_in: 12.hours)
    end
  end
  # rubocop:enable Metrics/AbcSize

  def notify_on_slack
    invitations_without_creneaux_by_motif_category.each do |motif_category, invitations|
      SlackClient.send_to_notif_channel(formated_string_for_slack_message(organisation, motif_category, invitations))
    end
  end

  def formated_string_for_slack_message(organisation, motif_category, invitations)
    string =
      "Créneaux indisponibles pour l'organisation #{organisation.name}" \
      " (Département: #{organisation.department.name})\n" \
      " Motif : #{motif_category.name}\n" \
      " Nombre d'invitations concernées : #{invitations.length}\n"

    post_codes = invitations.map(&:user_post_code).compact.uniq
    string += " Codes postaux : #{post_codes.join(', ')}\n" if post_codes.any?

    referent_ids = invitations.map(&:referent_ids).compact.uniq
    string += " Référents (rdvsp_ids) : #{referent_ids.join(', ')}\n" if referent_ids.any?

    string += " *L'organisation n'a pas d'email configuré et n'a pas été notifiée !*\n" if organisation.email.blank?

    string
  end

  def create_blocked_invitations_counter
    BlockedInvitationsCounter.create!(
      organisation:, number_of_invitations_affected: @invitations_without_creneaux.length
    )
  end

  def create_blocked_user
    @invitations_without_creneaux.map(&:user_id).uniq.each do |user_id|
      BlockedUser.create!(user_id:) unless BlockedUser.already_counted?(user_id:)
    end
  end
end
