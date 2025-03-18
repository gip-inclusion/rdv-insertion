module ImpersonationHelper
  def with_rdv_solidarites_impersonation_warning
    return {} unless agent_impersonated?

    {
      data: {
        controller: "confirmation-modal"
      }
    }
  end
end
