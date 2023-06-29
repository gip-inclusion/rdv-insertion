# Preview all emails at http://localhost:8000/rails/mailers/reply_transfer
class ReplyTransferPreview < ActionMailer::Preview
  def notify_agent_of_applicant_reply_for_notification
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
      invitation: nil,
      rdv: rdv,
      source_mail: source_mail,
      reply_body: body
    ).send("notify_agent_of_applicant_reply")
  end

  def notify_agent_of_applicant_reply_for_invitation
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
      rdv: nil,
      source_mail: source_mail,
      reply_body: body
    ).send("notify_agent_of_applicant_reply")
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
