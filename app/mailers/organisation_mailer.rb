class OrganisationMailer < ApplicationMailer
  def applicant_added(to:, subject:, content:, forwarded_attachments:)
    @content = content
    forwarded_attachments.each do |attachment|
      filename = attachment.original_filename
      attachments[filename] = File.read(filename)
    end
    mail(
      to: to,
      subject: subject
    )
  end
end
