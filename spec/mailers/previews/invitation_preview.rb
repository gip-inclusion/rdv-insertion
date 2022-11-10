# Preview all emails at http://localhost:8000/rails/mailers/invitation
class InvitationPreview < ActionMailer::Preview
  def invitation_for_rsa_orientation
    rdv_context = RdvContext.where.associated(:invitations).where(motif_category: "rsa_orientation").last
    invitation = rdv_context.invitations.last
    InvitationMailer.with(invitation: invitation, applicant: invitation.applicant)
                    .regular_invitation
  end

  def invitation_for_rsa_accompagnement
    invitation = Invitation.where(format: "email").last
    InvitationMailer.with(invitation: invitation, applicant: invitation.applicant)
                    .invitation_for_rsa_accompagnement
  end

  def invitation_for_rsa_accompagnement_social
    invitation = Invitation.where(format: "email").last
    InvitationMailer.with(invitation: invitation, applicant: invitation.applicant)
                    .invitation_for_rsa_accompagnement_social
  end

  def invitation_for_rsa_accompagnement_sociopro
    invitation = Invitation.where(format: "email").last
    InvitationMailer.with(invitation: invitation, applicant: invitation.applicant)
                    .invitation_for_rsa_accompagnement_sociopro
  end

  def invitation_for_rsa_orientation_on_phone_platform
    invitation = Invitation.where(format: "email").last
    InvitationMailer.with(invitation: invitation, applicant: invitation.applicant)
                    .invitation_for_rsa_orientation_on_phone_platform
  end

  def invitation_for_rsa_cer_signature
    invitation = Invitation.where(format: "email").last
    InvitationMailer.with(invitation: invitation, applicant: invitation.applicant)
                    .invitation_for_rsa_cer_signature
  end

  def invitation_for_rsa_insertion_offer
    invitation = Invitation.where(format: "email").last
    InvitationMailer.with(invitation: invitation, applicant: invitation.applicant)
                    .invitation_for_rsa_insertion_offer
  end

  def invitation_for_rsa_follow_up
    invitation = Invitation.where(format: "email").last
    InvitationMailer.with(invitation: invitation, applicant: invitation.applicant)
                    .invitation_for_rsa_follow_up
  end

  ### Reminders

  def invitation_for_rsa_orientation_reminder
    invitation = Invitation.where(format: "email").last
    InvitationMailer.with(invitation: invitation, applicant: invitation.applicant)
                    .invitation_for_rsa_orientation_reminder
  end

  def invitation_for_rsa_accompagnement_reminder
    invitation = Invitation.where(format: "email").last
    InvitationMailer.with(invitation: invitation, applicant: invitation.applicant)
                    .invitation_for_rsa_accompagnement_reminder
  end

  def invitation_for_rsa_accompagnement_social_reminder
    invitation = Invitation.where(format: "email").last
    InvitationMailer.with(invitation: invitation, applicant: invitation.applicant)
                    .invitation_for_rsa_accompagnement_social_reminder
  end

  def invitation_for_rsa_accompagnement_sociopro_reminder
    invitation = Invitation.where(format: "email").last
    InvitationMailer.with(invitation: invitation, applicant: invitation.applicant)
                    .invitation_for_rsa_accompagnement_sociopro_reminder
  end

  def invitation_for_rsa_orientation_on_phone_platform_reminder
    invitation = Invitation.where(format: "email").last
    InvitationMailer.with(invitation: invitation, applicant: invitation.applicant)
                    .invitation_for_rsa_orientation_on_phone_platform_reminder
  end

  def invitation_for_rsa_cer_signature_reminder
    invitation = Invitation.where(format: "email").last
    InvitationMailer.with(invitation: invitation, applicant: invitation.applicant)
                    .invitation_for_rsa_cer_signature_reminder
  end

  def invitation_for_rsa_insertion_offer_reminder
    invitation = Invitation.where(format: "email").last
    InvitationMailer.with(invitation: invitation, applicant: invitation.applicant)
                    .invitation_for_rsa_insertion_offer_reminder
  end

  def invitation_for_rsa_follow_up_reminder
    invitation = Invitation.where(format: "email").last
    InvitationMailer.with(invitation: invitation, applicant: invitation.applicant)
                    .invitation_for_rsa_follow_up_reminder
  end
end
