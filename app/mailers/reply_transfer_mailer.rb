class ReplyTransferMailer < ApplicationMailer
  before_action :set_invitation, only: [:forward_invitation_reply_to_organisation]
  before_action :set_rdv, only: [:forward_notification_reply_to_organisation]
  before action :set_organisation,
                only: [:forward_invitation_reply_to_organisation, :forward_notification_reply_to_organisation]
  before_action :set_organisation, :set_source_mail, :set_author, :set_applicant, :set_reply_subject,
                :set_reply_body, :set_attachment_names

  def forward_invitation_reply_to_organisation
    mail(to: @organisation.email, subject: "Réponse d'un usager à une invitation")
  end

  def forward_notification_reply_to_organisation
    mail(to: @organisation.email, subject: "Réponse d'un usager à une convocation")
  end

  def forward_to_default_mailbox
    mail(to: "support@rdv-insertion.fr", subject: "Réponse d'un usager")
  end

  private

  def set_invitation
    @invitation = params[:invitation]
  end

  def set_rdv
    @rdv = params[:rdv]
  end

  def set_organisation
    @organisation = @rdv.present? ? @rdv.organisation : @invitation.organisations.last
  end

  def set_source_mail
    @source_mail = params[:source_mail]
  end

  def set_author
    @author = @source_mail.header[:from]
  end

  def set_applicant
    @applicant = Applicant.find_by(email: @source_mail.from.first)
  end

  def set_reply_subject
    @reply_subject = @source_mail.subject
  end

  def set_reply_body
    @reply_body = params[:reply_body]
  end

  def set_attachment_names
    @attachment_names = @source_mail.attachments.map(&:filename).join(", ")
  end
end
