class SuperAdminMailer < ApplicationMailer
  def send_authentication_token(agent, token)
    @agent = agent
    @token = token
    mail(to: @agent.email, subject: "Votre code de connexion Super Admin")
  end
end
