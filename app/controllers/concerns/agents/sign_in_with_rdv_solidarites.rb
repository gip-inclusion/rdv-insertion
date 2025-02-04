module Agents::SignInWithRdvSolidarites
  extend ActiveSupport::Concern

  private

  def rdv_solidarites_credentials
    OpenStruct.new(request.env["omniauth.auth"]["info"]["agent"])
  end

  def retrieve_agent!
    return if authenticated_agent

    flash[:error] = "L'agent ne fait pas partie d'une organisation sur RDV-Insertion. \
                    Déconnectez-vous de RDV Solidarités puis essayez avec un autre compte."
    redirect_to @agent_return_to_url || root_path
  end

  def mark_agent_as_logged_in!
    return if authenticated_agent.update(last_sign_in_at: Time.zone.now)

    flash[:error] = authenticated_agent.errors.full_messages
    redirect_to @agent_return_to_url || root_path
  end

  def authenticated_agent
    @authenticated_agent ||= Agent.find_by(email: rdv_solidarites_credentials.email)
  end
end
