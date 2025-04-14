module InvitationsHelper
  def show_invitation?(format, invitation_formats)
    invitation_formats.include?(format)
  end

  def sms_invitation_disabled_for?(user, follow_up, user_is_archived)
    !user.phone_number_is_mobile? || user_is_archived || follow_up.rdv_pending? ||
      follow_up.closed?
  end

  def email_invitation_disabled_for?(user, follow_up, user_is_archived)
    !user.email? || user_is_archived || follow_up.rdv_pending? || follow_up.closed?
  end

  def postal_invitation_disabled_for?(user, follow_up, user_is_archived)
    !user.address? || user_is_archived || follow_up.rdv_pending? || follow_up.closed?
  end

  def invitations_by_format(invitations, invitation_formats)
    invitation_formats.index_with { |_invitation_format| [] }.merge!(
      invitations.group_by(&:format)
                 .select { |format| invitation_formats.include?(format) }
                 .transform_values { |invites| invites.sort_by(&:created_at).reverse }
    )
  end

  def max_number_of_invitations_in_any_format(invitations_by_format)
    invitations_by_format.values.map(&:count).max
  end

  def not_delivered_tooltip_content(format)
    case format
    when "sms"
      "Le SMS n'a pas pu être délivré. Causes possibles : numéro incorrect, problème de l'opérateur, etc. " \
      "Nous vous invitons à vérifier le format du numéro et à le modifier si nécessaire."
    when "email"
      "L’email n'a pas pu être remis. Causes possibles : boîte de réception pleine ou indisponible, " \
      "adresse email incorrecte ou inexistante, filtre anti-spams, etc. " \
      "Nous vous invitons à vérifier le format de l’adresse email et de réessayer d'envoyer l'invitation."
    end
  end
end
