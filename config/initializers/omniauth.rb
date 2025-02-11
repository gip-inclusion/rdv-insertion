Rails.application.config.middleware.use OmniAuth::Builder do
  provider :rdv_service_public, ENV["RDV_SOLIDARITES_OAUTH_APP_ID"], ENV["RDV_SOLIDARITES_OAUTH_APP_SECRET"],
           scope: "write", base_url: ENV["RDV_SOLIDARITES_URL"]

  on_failure do |env|
    Sentry.capture_exception(env["omniauth.error"])

    # On n'est pas dans un controller, donc on ne peut pas directement
    # manipuler le flash et faire des redirection
    Website::StaticPagesController.action(:welcome).call(env)
  end
end
