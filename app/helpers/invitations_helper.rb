module InvitationsHelper
  def show_invitation?(format, invitation_formats)
    invitation_formats.include?(format)
  end

  def sms_invitation_disabled_for?(user, follow_up, user_archived)
    !user.phone_number_is_mobile? || user_archived || follow_up.rdv_pending? ||
      follow_up.closed?
  end

  def email_invitation_disabled_for?(user, follow_up, user_archived)
    !user.email? || user_archived || follow_up.rdv_pending? || follow_up.closed?
  end

  def postal_invitation_disabled_for?(user, follow_up, user_archived)
    !user.address? || user_archived || follow_up.rdv_pending? || follow_up.closed?
  end

  def invitation_dates_by_format(invitations, invitation_formats)
    invitation_dates_by_formats = invitation_formats.index_with { |_invitation_format| [] }
    invitation_dates_by_formats.merge!(
      invitations.group_by(&:format)
                 .select { |format| invitation_formats.include?(format) }
                 .transform_values { |invites| invites.map(&:created_at).sort.reverse }.to_h
    )
    invitation_dates_by_formats
  end

  def max_number_of_invitations_for_a_format(invitation_dates_by_formats)
    invitation_dates_by_formats.values.map(&:count).max
  end
end
