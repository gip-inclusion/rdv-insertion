class ActiveStorage::BlobPolicy < ApplicationPolicy
  def show?
    # blobs routes are public, but the only blobs we want to be publicly accessible are logos
    record.attachments.all? { |attachment| attachment.name == "logo" }
  end
end
