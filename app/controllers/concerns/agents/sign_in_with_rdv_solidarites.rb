module Agents::SignInWithRdvSolidarites
  extend ActiveSupport::Concern

  private

  def rdv_solidarites_credentials
    OpenStruct.new(request.env["omniauth.auth"]["info"]["agent"])
  end

  def retrieve_agent!
    return if authenticated_agent

    respond_to do |format|
      format.json do
        render json: { success: false, errors: ["L'agent ne fait pas partie d'une organisation sur RDV-Insertion"] },
               status: :forbidden
      end

      format.html do
        flash[:error] = "L'agent ne fait pas partie d'une organisation sur RDV-Insertion. \
                        Déconnectez-vous de RDV Solidarités puis essayez avec un autre compte."
        redirect_to @agent_return_to_url || root_path
      end
    end
  end

  def mark_agent_as_logged_in!
    return if authenticated_agent.update(last_sign_in_at: Time.zone.now)

    render json: { success: false, errors: authenticated_agent.errors.full_messages }, status: :unprocessable_entity
  end

  def authenticated_agent
    @authenticated_agent ||= Agent.find_by(email: rdv_solidarites_credentials.email)
  end
end
