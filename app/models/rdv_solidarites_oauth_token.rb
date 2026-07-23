class RdvSolidaritesOauthToken < ApplicationRecord
  belongs_to :agent

  encrypts :api_token, :refresh_token

  def refresh!(expired_api_token)
    with_lock do
      # the api token might have been refreshed by another process since we acquired the lock
      return if api_token != expired_api_token

      access_token = RdvSolidaritesOauthClient.new(api_token:, refresh_token:).refresh!
      update!(api_token: access_token.token, refresh_token: access_token.refresh_token)
    end
  end
end
