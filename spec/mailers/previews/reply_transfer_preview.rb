# Preview all emails at http://localhost:8000/rails/mailers/reply_transfer
class ReplyTransferPreview < ActionMailer::Preview
  def forward_notification_reply_to_organisation
    rdv = Notification.last.rdv

    source_mail = Mail.new do
      from rdv.applicants.first.email

      subject "Re: [Important - RSA] Vous êtes convoquée à un rendez-vous d'orientation"

      text_part do
        body "Bonjour,\nVoici une phrase après un saut de ligne."
      end

      attachments["signature.svg"] = { mime_type: "image/svg+xml", content: "" }
    end

    body = <<~MARKDOWN
      Bonjour,
      Voici une phrase après un saut de ligne.

      Voici une autre phrase après deux sauts de ligne (saut de paragraphe)
    MARKDOWN

    ReplyTransferMailer.with(
      rdv: rdv,
      source_mail: source_mail,
      reply_body: body
    ).send("forward_notification_reply_to_organisation")
  end

  def forward_invitation_reply_to_organisation
    invitation = Invitation.last

    source_mail = Mail.new do
      from invitation.applicant.email

      subject "Re: [RSA]: Votre rendez-vous d'orientation dans le cadre de votre RSA"

      text_part do
        body "Bonjour,\nVoici une phrase après un saut de ligne."
      end

      attachments["signature.svg"] = { mime_type: "image/svg+xml", content: "" }
    end

    body = <<~MARKDOWN
      Bonjour,
      Voici une phrase après un saut de ligne.

      Voici une autre phrase après deux sauts de ligne (saut de paragraphe)
    MARKDOWN

    ReplyTransferMailer.with(
      invitation: invitation,
      source_mail: source_mail,
      reply_body: body
    ).send("forward_invitation_reply_to_organisation")
  end

  def forward_to_default_mailbox
    source_mail = Mail.new do
      from Applicant.last.email

      subject "Re: [RSA]: Votre rendez-vous d'orientation dans le cadre de votre RSA"

      text_part do
        body "Bonjour,\nVoici une phrase après un saut de ligne."
      end

      attachments["signature.svg"] = { mime_type: "image/svg+xml", content: "" }
    end

    body = <<~MARKDOWN
      Bonjour,
      Voici une phrase après un saut de ligne.

      Voici une autre phrase après deux sauts de ligne (saut de paragraphe)
    MARKDOWN

    ReplyTransferMailer.with(
      source_mail: source_mail,
      reply_body: body
    ).send("forward_to_default_mailbox")
  end
end
