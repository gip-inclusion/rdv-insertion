module RdvSolidaritesAgentConcern
  private

  def retrieve_agent!
    return if current_agent

    render json: { success: false, errors: ["L'agent ne fait pas partie d'une organisation sur RDV-Insertion"] },
           status: :unprocessable_entity
  end

  def mark_as_logged_in!
    return if current_agent.has_logged_in? || current_agent.update(has_logged_in: true)

    render json: { success: false, errors: current_agent.errors.full_messages }, status: :unprocessable_entity
  end

  def current_agent
    @current_agent ||= Agent.find_by(email: rdv_solidarites_session.uid)
  end
end
