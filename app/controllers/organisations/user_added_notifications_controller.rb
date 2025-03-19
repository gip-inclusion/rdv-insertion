module Organisations
  class UserAddedNotificationsController < ApplicationController
    include UserAddedNotificationsHelper

    before_action :set_department, :set_organisation, :set_user

    def create
      OrganisationMailer.user_added(
        to: @organisation.email,
        subject: user_added_notification_subject,
        content: user_added_notification_content(@user, @organisation),
        custom_content:,
        user_attachements:, reply_to: current_agent.email
      ).deliver_now
      flash.now[:success] = "L'email a bien été envoyé à l'organisation"
      respond_to :turbo_stream
    end

    private

    def set_user
      @user = @organisation.users.find(email_params[:user_id])
    end

    def set_organisation
      @organisation = @department.organisations.find(params[:organisation_id])
    end

    def set_department
      @department = policy_scope(Department).find(current_department_id)
    end

    def email_params
      params.expect(email: [:user_id, :custom_content, :attachments])
    end

    def user_attachements
      UploadedFileSanitizer.sanitize((email_params[:attachments] || []).compact_blank)
    end

    def custom_content
      ActionView::Base.full_sanitizer.sanitize(email_params[:custom_content])
    end
  end
end
