require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class RdvSolidarites < OmniAuth::Strategies::OAuth2
      option :client_options, {
        :site => ENV['RDV_SOLIDARITES_URL'],
        :authorize_url => "#{ENV['RDV_SOLIDARITES_URL']}/oauth/authorize",
        :token_url => "#{ENV['RDV_SOLIDARITES_URL']}/oauth/token"
      }

      info do
        # Envoie une requête sur l'endpoint d'api qui donne les infos de l'agent courant
        access_token.get("/api/v1/agents/me.json").parsed
      end
    end
  end
end
