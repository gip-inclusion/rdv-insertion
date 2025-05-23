module Users
  class ParcoursDocumentsController < ApplicationController
    before_action :set_user
    before_action :set_parcours_document, only: [:destroy, :show, :update]

    def show
      authorize @parcours_document
      redirect_to @parcours_document.file.url, allow_other_host: true
    end

    def create
      @parcours_document = ParcoursDocument.new(parcours_document_params)
      authorize @parcours_document

      if @parcours_document.save
        redirect_to structure_user_parcours_path(user_id: @user.id)
      else
        turbo_stream_display_error_modal(@parcours_document.errors.full_messages)
      end
    end

    def update
      authorize @parcours_document
      if @parcours_document.update(parcours_document_params)
        redirect_to structure_user_parcours_path(user_id: @user.id)
      else
        turbo_stream_display_error_modal(@parcours_document.errors.full_messages)
      end
    end

    def destroy
      authorize @parcours_document

      if @parcours_document.destroy
        redirect_to structure_user_parcours_path(user_id: @user.id)
      else
        turbo_stream_display_error_modal(@parcours_document.errors.full_messages)
      end
    end

    private

    def parcours_document_params
      params
        .expect(parcours_document: [:type, :file, :user_id, :document_date])
        .merge(agent: current_agent, user: @user)
        .merge(department: current_department)
    end

    def set_parcours_document
      @parcours_document = ParcoursDocument.find_signed!(params[:id].to_s)
    end

    def set_user
      @user = policy_scope(User).find(params[:user_id])
    end
  end
end
