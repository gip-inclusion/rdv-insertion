class EmailSendingsController < ApplicationController
  def create
    OrganisationMailer.applicant_added(
      to: email_params[:to], subject: email_params[:subject], content: email_params[:content],
      forwarded_attachments: email_params[:attachments]
    ).deliver_now
  end

  private

  def email_params
    params[:email]
  end
end
