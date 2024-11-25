module CguHelper
  def should_accept_cgu?
    return false if current_agent.nil?
    return false if agent_impersonated?

    current_agent.cgu_accepted_at.nil?
  end
end
