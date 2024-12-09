module DpaHelper
  def should_accept_dpa?
    return false if current_agent.nil? || current_organisation.nil?
    return false if agent_impersonated?

    current_organisation.dpa_agreement.nil? && policy(current_organisation).send(:configure?)
  end
end
