module RdvSolidaritesMailerHelper
  def rdv_solidarites_invitations_url(uuid)
    ENV["RDV_SOLIDARITES_URL"] + "/i/r/#{uuid}"
  end
end
