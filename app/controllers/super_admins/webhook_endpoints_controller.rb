module SuperAdmins
  class WebhookEndpointsController < SuperAdmins::ApplicationController
    def duplicate
      webhook_endpoint = WebhookEndpoint.find(params[:id])
      
      new_webhook_endpoint = webhook_endpoint.dup
      organisation = Organisation.find_by(id: webhook_endpoint_params[:target_id])
      new_webhook_endpoint.organisation = organisation

      if new_webhook_endpoint.save
        flash[:success] = "Le webhook a bien été dupliqué vers l'organisation : #{organisation}"
      else
        flash[:error] = "Impossible de dupliquer le webhook: #{new_webhook_endpoint.errors.full_messages.join(', ')}"
      end
      redirect_to super_admins_webhook_endpoints_path
    end

    private

    def webhook_endpoint_params
      params.require(:webhook_endpoint).permit(:target_id)
    end
  end
end