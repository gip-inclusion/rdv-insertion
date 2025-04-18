module PaperTrailConcern
  extend ActiveSupport::Concern

  included do
    before_action :set_paper_trail_whodunnit
  end

  private

  def user_for_paper_trail
    return "Aucun agent connecté" unless current_agent

    if agent_impersonated?
      "[Agent Impersonné] #{current_agent.name_for_paper_trail}. Impersonné par #{super_admin_impersonating.email}"
    else
      "[Agent] #{current_agent.name_for_paper_trail}"
    end
  end
end
