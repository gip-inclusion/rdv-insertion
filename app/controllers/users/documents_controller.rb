module Users
  class DocumentsController < ApplicationController
    before_action :set_user

    def create
      @document = Document.create(document_params)

      if @document.errors.any?
        turbo_stream_prepend_flash_message(error: @document.errors.full_messages.join(", "))
      else
        turbo_stream_replace(
          "documents_list_#{document_params[:document_type]}",
          "documents/documents_list",
          { user: @user, document_type: document_params[:document_type] }
        )
      end
    end

    def destroy
      @document = Document.find_by!(id: params[:id], user: @user, agent: current_agent)
      @document.destroy!

      turbo_stream_remove("document_#{@document.id}")
    end

    private

    def document_params
      params.require(:document)
            .permit(:document_type, :file, :user_id)
            .merge(agent: current_agent, user: @user)
            .merge(Current.structure_type => current_structure, department: current_department)
    end

    def set_user
      @user = policy_scope(User).find(params[:user_id])
    end
  end
end
