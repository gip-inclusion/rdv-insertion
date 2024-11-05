Rails.application.config.middleware.use OmniAuth::Builder do
  provider :rdv_service_public, ENV["RDV_SOLIDARITES_OAUTH_APP_ID"], ENV["RDV_SOLIDARITES_OAUTH_APP_SECRET"],
           scope: "write", base_url: ENV["RDV_SOLIDARITES_URL"]

  on_failure do |env|
    provider = env["omniauth.error.strategy"].class.name.demodulize

    Sentry.set_context(
      "omniauth_env",
      {
        provider: provider,
        full_env: env.transform_values { |value| value.is_a?(String) ? value : value.inspect },
      }
    )

    Sentry.capture_exception(env["omniauth.error"])

    SessionsController.action(:new).call(env)
  end
end
