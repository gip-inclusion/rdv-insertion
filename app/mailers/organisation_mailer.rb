class OrganisationMailer < ApplicationMailer
  def applicant_added(to:, subject:, content:, applicant_attachements:, reply_to:)
    @content = content
    applicant_attachements.each do |attachment|
      attachments[attachment.original_filename] = attachment.read
    end
    mail(
      to: to,
      subject: subject,
      reply_to: reply_to
    )
  end
end
