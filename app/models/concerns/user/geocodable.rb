module User::Geocodable
  extend ActiveSupport::Concern

  included do
    has_one :address_geocoding, dependent: :destroy
    before_save :track_address_changed
    after_commit :assign_address_geocoding, if: :should_assign_address_geocoding?
    after_commit :nullify_address_changed
  end

  private

  def track_address_changed
    return if @address_changed

    # we have to do this, we cannot use address_previously_changed? in the after commit block since when a user is
    # commited to the db, a lot of saves are triggered in transactions so the previous_changes hash doesn't necessarily
    # contain the address attribute even though it has changed
    @address_changed = address_changed?
  end

  def should_assign_address_geocoding?
    @address_changed
  end

  def nullify_address_changed
    @address_changed = nil
  end

  def assign_address_geocoding
    RetrieveAndAssignUserAddressGeocodingJob.perform_async(id)
  end
end
