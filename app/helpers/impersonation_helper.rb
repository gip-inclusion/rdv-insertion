module ImpersonationHelper
  def with_rdv_solidarites_impersonation_warning(url:)
    return {} unless agent_impersonated?

    {
      data: {
        turbo_confirm: confirm_modal(
          content: render("common/rdvs_impersonation_warning", url:)
        )
      }
    }
  end
end
