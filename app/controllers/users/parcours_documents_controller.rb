module Users
  class ParcoursDocumentsController < ApplicationController
    before_action :set_user
    before_action :set_parcours_document, only: :destroy

    def create
      @parcours_document = ParcoursDocument.create(parcours_document_params)

      if @parcours_document.errors.any?
        turbo_stream_prepend_flash_message(error: @parcours_document.errors.full_messages.join(". "))
      else
        turbo_stream_replace(
          "documents_list_#{@parcours_document.type.downcase}",
          "parcours_documents/documents_list",
          { user: @user, type: @parcours_document.type.downcase }
        )
      end
    end

    def destroy
      if @parcours_document.destroy
        turbo_stream_remove(@parcours_document)
      else
        turbo_stream_prepend_flash_message(error: "Impossible de supprimer ce document")
      end
    end

    private

    def parcours_document_params
      params.require(:parcours_document)
            .permit(:type, :file, :user_id)
            .merge(agent: current_agent, user: @user)
            .merge(department: current_department)
    end

    def set_parcours_document
      @parcours_document = ParcoursDocument.find(params[:id])
      authorize @parcours_document, :destroy?
    end

    def set_user
      @user = policy_scope(User).find(params[:user_id])
    end
  end
end
