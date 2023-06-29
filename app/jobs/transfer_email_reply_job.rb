class TransferEmailReplyJob < ApplicationJob
  # Pour éviter de fuiter des données personnelles dans les logs
  self.log_arguments = false

  INVITATION_UUID_EXTRACTOR = /invitation\+([A-Z0-9-]*)@reply\.rdv-insertion\.fr/
  RDV_UUID_EXTRACTOR = /rdv\+([a-f0-9-]*)@reply\.rdv-insertion\.fr/

  def perform(brevo_hash)
    @brevo_hash = brevo_hash.with_indifferent_access

    if invitation || rdv
      notify_agents
    else
      forward_to_default_mailbox
    end
  end

  private

  def notify_agents
    ReplyTransferMailer.notify_agent_of_applicant_reply(
      invitation: invitation,
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
    Rdv.find_by(uuid: uuid) if rdv_uuid
  end

  def invitation
    Invitation.find_by(uuid: uuid) if invitation_uuid
  end

  def invitation_uuid
    source_mail.to.first.start_with?("invitation") &&
      source_mail.to.first.match(INVITATION_UUID_EXTRACTOR)&.captures&.first
  end

  def rdv_uuid
    source_mail.to.first.start_with?("rdv") &&
      source_mail.to.first.match(RDV_UUID_EXTRACTOR)&.captures&.first
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
  def source_mail # rubocop:disable Metrics/AbcSize
    payload = @brevo_hash

    @source_mail ||= Mail.new do
      headers payload[:Headers]
      subject payload[:Subject]

      if payload[:RawTextBody].present?
        text_part do
          body payload[:RawTextBody]
        end
      end

      if payload[:RawHtmlBody].present?
        html_part do
          content_type "text/html; charset=UTF-8"
          body payload[:RawHtmlBody]
        end
      end

      payload.fetch(:Attachments, []).each do |attachment_payload|
        attachments[attachment_payload[:Name]] = {
          mime_type: attachment_payload[:ContentType],
          content: "" # brevo webhook does not provide the content of attachments
        }
      end
    end
  end
end
