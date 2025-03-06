module ImpersonationHelper
  def with_rdv_solidarites_impersonation_warning(modal_dom_id)
    return {} unless agent_impersonated?

    {
      data: {
        turbo_confirm: true,
        turbo_confirm_template: modal_dom_id
      }
    }
  end
end
