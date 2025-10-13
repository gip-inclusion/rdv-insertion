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
    notify_on_mattermost
  end

  private

  def notify_agents_of_invitation_reply
    ReplyTransferMailer.with(
      invitation: invitation,
      reply_body: extracted_response,
      source_mail: source_mail
    ).forward_invitation_reply_to_organisation.deliver_now
  end

  def notify_agents_of_notification_reply
    ReplyTransferMailer.with(
      rdv: rdv,
      reply_body: extracted_response,
      source_mail: source_mail
    ).forward_notification_reply_to_organisation.deliver_now
  end

  def forward_to_default_mailbox
    ReplyTransferMailer.with(
      reply_body: extracted_response,
      source_mail: source_mail
    ).forward_to_default_mailbox.deliver_now
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

  def notify_on_mattermost
    MattermostClient.send_to_notif_channel(
      "📩 Un email d'un usager vient d'être transféré #{record_id_mattermost_mention}"
    )
  end

  def record_id_mattermost_mention
    if invitation
      "(Invitation #{invitation.id})"
    elsif rdv
      "(RDV #{rdv.id})"
    else
      ""
    end
  end
end
