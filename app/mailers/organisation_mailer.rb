class OrganisationMailer < ApplicationMailer
  def user_added(to:, subject:, content:, user_attachements:, reply_to:)
    @content = content
    user_attachements.each do |attachment|
      attachments[attachment.original_filename] = attachment.read
    end
    mail(
      to: to,
      subject: subject,
      reply_to: reply_to
    )
  end
end
