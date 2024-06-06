module InvitationsHelper
  def show_invitation?(format, invitation_formats)
    invitation_formats.include?(format)
  end

  def sms_invitation_disabled_for?(user, follow_up, department)
    !user.phone_number_is_mobile? || user.archived_in?(department) || follow_up.rdv_pending? || follow_up.closed?
  end

  def email_invitation_disabled_for?(user, follow_up, department)
    !user.email? || user.archived_in?(department) || follow_up.rdv_pending? || follow_up.closed?
  end

  def postal_invitation_disabled_for?(user, follow_up, department)
    !user.address? || user.archived_in?(department) || follow_up.rdv_pending? || follow_up.closed?
  end

  def invitation_attribute_by_format(invitations, invitation_formats, &block)
    invitation_formats.index_with { |_invitation_format| [] }.merge!(
      invitations.group_by(&:format)
                 .select { |format| invitation_formats.include?(format) }
                 .transform_values(&block).to_h
    )
  end

  def invitation_dates_by_format(invitations, invitation_formats)
    invitation_attribute_by_format(invitations, invitation_formats) do |invites|
      invites.map(&:created_at).sort.reverse
    end
  end

  def invitation_delivery_status_by_format(invitations, invitation_formats)
    invitation_attribute_by_format(invitations, invitation_formats) do |invites|
      invites.map(&:human_delivery_status_and_date)
    end
  end

  def format_delivery_datetime(delivery_status_received_at)
    # Revoir ca, faire de delivery_status un enum avec un hash de traduction
    # Gérer les cas d'erreurs en bounce
    delivery_status_received_at&.strftime("%d/%m/%Y %H:%M")
  end

  def max_number_of_invitations_for_a_format(invitation_dates_by_formats)
    invitation_dates_by_formats.values.map(&:count).max
  end
end
