module AdminJobsAgentHelper
  def admin_jobs_agent_session
    # Afin de vérifier la validité des invitations (créneaux dispos) dans les jobs, il faut utiliser un agent pour l'api
    # Je propose ici d'utiliser un agent admin qui sera créé en db au préalable pour envoyer les invitations
    # On réutilise le systéme de secret partagé implémenté avec IC plutot que le système de token d'accés

    agent = Agent.find_by(email: "admin_jobs@rdv-insertion.fr")
    @admin_jobs_agent_session ||= RdvSolidaritesSession::WithSharedSecret.new(
      uid: agent.email,
      x_agent_auth_signature: agent.signature_auth_with_shared_secret
    )
  end
end
