module SuperAdmins
  module SessionsConcern
    private

    def switch_accounts
      reset_session
      set_new_session_credentials
      set_new_current_agent
    end

    def set_new_session_credentials
      session[:agent_id] = @new_agent.id
      session[:rdv_solidarites_credentials] = {
        uid: @new_agent.email,
        x_agent_auth_signature: @new_agent.signature_auth_with_shared_secret,
        super_admin_id: @super_admin_id
      }
    end

    def set_new_current_agent
      Current.agent = @new_agent
    end
  end
end
