module UserListUpload::CreneauxSnapshotsHelper
  def rdv_solidarites_planning_url(organisation)
    "#{ENV['RDV_SOLIDARITES_URL']}/admin/organisations/" \
      "#{organisation.rdv_solidarites_organisation_id}/planning/agenda"
  end

  def creneaux_snapshot_refresh_delay_in_ms(user_list_upload)
    ((user_list_upload.creneaux_snapshot_retrieval_expires_at - Time.current) * 1000).to_i
  end
end
