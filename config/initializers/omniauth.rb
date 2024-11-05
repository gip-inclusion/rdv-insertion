Rails.application.config.middleware.use OmniAuth::Builder do
  provider :rdv_service_public, ENV["RDV_SOLIDARITES_OAUTH_APP_ID"], ENV["RDV_SOLIDARITES_OAUTH_APP_SECRET"],
           scope: "write", base_url: ENV["RDV_SOLIDARITES_URL"]

  on_failure do |env|
    Sentry.capture_exception(env["omniauth.error"])

    SessionsController.action(:new).call(env)
  end
end
