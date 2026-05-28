module UserListUpload::CreneauxSnapshotsHelper
  def rdv_solidarites_planning_url(organisation)
    "#{ENV['RDV_SOLIDARITES_URL']}/admin/organisations/" \
      "#{organisation.rdv_solidarites_organisation_id}/planning/agenda"
  end
end
