module SuperAdmins
  module Impersonate
    private

    def set_impersonation_session
      super_admin_auth = session[:agent_auth]
      clear_session

      timestamp = Time.zone.now.to_i
      session[:agent_auth] = {
        id: @agent_to_impersonate.id,
        origin: "impersonate",
        created_at: timestamp,
        signature: @agent_to_impersonate.sign_with(timestamp),
        # we generate a session key if it's not present because it means the agent has never logged in
        session_key: @agent_to_impersonate.retrieve_or_generate_session_key!,
        super_admin_auth: super_admin_auth
      }
    end

    def remove_impersonated_from_session
      super_admin_auth = session.dig("agent_auth", "super_admin_auth")
      clear_session

      session[:agent_auth] = super_admin_auth
    end
  end
end
