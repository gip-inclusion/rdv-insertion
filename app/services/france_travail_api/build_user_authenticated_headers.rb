module FranceTravailApi
  class BuildUserAuthenticatedHeaders < BaseService
    def initialize(user:)
      @user = user
    end

    def call
      access_token = call_service!(RetrieveAccessToken).access_token
      user_token = call_service!(RetrieveUserToken, user: @user, access_token: access_token).user_token

      result.headers = {
        "ft-jeton-usager" => user_token,
        "Authorization" => "Bearer #{access_token}",
        "Content-Type" => "application/json",
        "Accept" => "application/json"
      }
    end
  end
end
