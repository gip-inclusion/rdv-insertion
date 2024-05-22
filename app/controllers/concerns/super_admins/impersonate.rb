module SuperAdmins
  module Impersonate
    private

    def impersonate_agent
      set_session_credentials
    end

    def set_session_credentials
      super_admin_auth = session[:agent_auth]
      clear_session

      timestamp = Time.zone.now.to_i
      session[:agent_auth] = {
        id: @agent_to_impersonate.id,
        origin: "impersonate",
        created_at: timestamp,
        signature: @agent_to_impersonate.sign_with(timestamp),
        super_admin_auth: super_admin_auth
      }
    end

    def unimpersonate_agent
      super_admin_auth = session.dig("agent_auth", "super_admin_auth")
      clear_session

      session[:agent_auth] = super_admin_auth
    end
  end
end
