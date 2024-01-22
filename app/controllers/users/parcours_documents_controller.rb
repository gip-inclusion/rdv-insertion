module Users
  class ParcoursDocumentsController < ApplicationController
    before_action :set_user

    def create
      @parcours_document = ParcoursDocument.create(parcours_document_params)

      if @parcours_document.errors.any?
        turbo_stream_prepend_flash_message(error: @parcours_document.errors.full_messages.join(". "))
      else
        turbo_stream_replace(
          "documents_list_#{parcours_document_params[:document_type]}",
          "parcours_documents/documents_list",
          { user: @user, document_type: parcours_document_params[:document_type] }
        )
      end
    end

    def destroy
      @parcours_document = ParcoursDocument.find_by!(id: params[:id], user: @user, agent: current_agent)
      @parcours_document.destroy!

      turbo_stream_remove(@parcours_document)
    end

    private

    def parcours_document_params
      params.require(:parcours_document)
            .permit(:document_type, :file, :user_id)
            .merge(agent: current_agent, user: @user)
            .merge(department: current_department)
    end

    def set_user
      @user = policy_scope(User).find(params[:user_id])
    end
  end
end
