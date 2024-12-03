class FranceTravailHeaders
  def self.for_user(user)
    FranceTravailApi::BuildUserAuthenticatedHeaders.call(user: user).headers
  end

  def self.for_client
    access_token = FranceTravailApi::RetrieveAccessToken.call.access_token
    {
      "Authorization" => "Bearer #{access_token}",
      "Content-Type" => "application/json"
    }
  end
end
