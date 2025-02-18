module UserListUploads
  class OrganisationAssignationsController < ApplicationController
    before_action :set_user_list_upload, :set_user_row, only: [:new, :create]

    def new
      @organisations = @user_list_upload.organisations
    end

    def create
      @organisation = @user_list_upload.organisations.find do |o|
        o.id == organisation_assignation_params[:assigned_organisation_id].to_i
      end

      if @user_row.update(assigned_organisation_id: @organisation.id)
        turbo_stream_display_modal(
          partial: "user_list_uploads/organisation_assignations/organisation_has_been_assigned",
          locals: { organisation: @organisation, user_row: @user_row }
        )
      else
        turbo_stream_replace_error_list_with(@user_row.errors.full_messages)
      end
    end

    private

    def set_user_list_upload
      @user_list_upload = UserListUpload.find(params[:user_list_upload_id])
      authorize @user_list_upload, :edit?
    end

    def set_user_row
      @user_row = @user_list_upload.user_rows.find(params[:user_row_id])
    end

    def organisation_assignation_params
      params.expect(user_list_upload_user_row: :assigned_organisation_id)
    end
  end
end
