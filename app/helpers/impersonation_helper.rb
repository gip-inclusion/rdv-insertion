module ImpersonationHelper
  def with_rdvs_impersonation_warning(url)
    return {} unless agent_impersonated?

    {
      data: {
        turbo_confirm: true,
        turbo_confirm_template: raw(render("common/rdvs_impersonation_warning", url:)) # rubocop:disable Rails/OutputSafety
      }
    }
  end
end
