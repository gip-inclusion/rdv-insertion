module UserListUpload::CreneauxSnapshotRetrievable
  extend ActiveSupport::Concern

  CRENEAUX_SNAPSHOT_RETRIEVAL_TIMEOUT = 2.minutes

  def retrievable_creneaux_snapshot?
    category_configuration_id? && !rdv_with_referents?
  end

  def creneaux_snapshot_retrieval_expires_at
    created_at + CRENEAUX_SNAPSHOT_RETRIEVAL_TIMEOUT
  end

  def awaiting_creneaux_snapshot?
    creneaux_snapshot.nil? && creneaux_snapshot_retrieval_expires_at.future?
  end
end
