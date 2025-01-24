module Organisations
  class UserAddedNotificationsController < ApplicationController
    def create
      OrganisationMailer.user_added(
        to: email_params[:to], subject: email_params[:subject], content: email_params[:content],
        user_attachements:, reply_to: current_agent.email
      ).deliver_now
      flash.now[:success] = "L'email a bien été envoyé à l'organisation"
      respond_to :turbo_stream
    end

    private

    def email_params
      params[:email]
    end

    def user_attachements
      (email_params[:attachments] || []).compact_blank
    end
  end
end
