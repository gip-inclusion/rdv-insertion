require "omniauth/strategies/rdv_solidarites"

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :rdv_solidarites, ENV["RDV_SOLIDARITES_OAUTH_APP_ID"], ENV["RDV_SOLIDARITES_OAUTH_APP_SECRET"], scope: "write"
end
