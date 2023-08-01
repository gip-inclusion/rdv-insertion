class TransferEmailReplyJob < ApplicationJob
  INVITATION_UUID_EXTRACTOR = /invitation\+([A-Z0-9-]*)@reply\.rdv-insertion\.fr/
  RDV_UUID_EXTRACTOR = /rdv\+([a-f0-9-]*)@reply\.rdv-insertion\.fr/

  def perform(brevo_hash)
    @brevo_hash = brevo_hash.deep_symbolize_keys

    if invitation
      notify_agents_of_invitation_reply
    elsif rdv
      notify_agents_of_notification_reply
    else
      forward_to_default_mailbox
    end
  end

  private

  def notify_agents_of_invitation_reply
    ReplyTransferMailer.forward_invitation_reply_to_organisation(
      invitation: invitation,
      reply_body: extracted_response,
      source_mail: source_mail
    ).deliver_now
  end

  def notify_agents_of_notification_reply
    ReplyTransferMailer.forward_notification_reply_to_organisation(
      rdv: rdv,
      reply_body: extracted_response,
      source_mail: source_mail
    ).deliver_now
  end

  def forward_to_default_mailbox
    ReplyTransferMailer.forward_to_default_mailbox(
      reply_body: extracted_response,
      source_mail: source_mail
    ).deliver_now
  end

  def rdv
    @rdv ||= Rdv.find_by(uuid: rdv_uuid) if rdv_uuid
  end

  def invitation
    @invitation ||= Invitation.find_by(uuid: invitation_uuid) if invitation_uuid
  end

  def invitation_uuid
    @invitation_uuid ||= receiver_address.match(INVITATION_UUID_EXTRACTOR)&.captures&.first
  end

  def rdv_uuid
    @rdv_uuid ||= receiver_address.match(RDV_UUID_EXTRACTOR)&.captures&.first
  end

  def receiver_address
    source_mail.to.first
  end

  def extracted_response
    # brevo provides us with both
    #   - the RAW email body (text + HTML)
    #   - a smart extraction of the content in markdown format
    # We chose to use the smart extract because it already does all
    # the hard work of excluding the quoted reply part.
    [@brevo_hash[:ExtractedMarkdownMessage], @brevo_hash[:ExtractedMarkdownSignature]].compact.join("\n\n")
  end

  # @return [Mail::Message]
  def source_mail
    payload = @brevo_hash

    @source_mail ||= Mail.new do
      headers payload[:Headers]
      subject payload[:Subject]

      payload.fetch(:Attachments, []).each do |attachment_payload|
        attachments[attachment_payload[:Name]] = {
          mime_type: attachment_payload[:ContentType],
          content: "" # brevo webhook does not provide the content of attachments
        }
      end
    end
  end
end
