module UserListUpload::CreneauxSnapshotsHelper
  def creneaux_snapshot_refresh_delay_in_ms(expires_at)
    ((expires_at - Time.current) * 1000).to_i
  end
end
