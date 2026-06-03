module Organisation::RdvSolidaritesUrls
  extend ActiveSupport::Concern

  def rdv_solidarites_url
    "#{ENV['RDV_SOLIDARITES_URL']}/admin/organisations/#{rdv_solidarites_organisation_id}"
  end

  def rdv_solidarites_configuration_url
    "#{rdv_solidarites_url}/configuration"
  end

  def rdv_solidarites_planning_url
    "#{rdv_solidarites_url}/planning/agenda"
  end
end
