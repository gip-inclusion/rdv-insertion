module User::Geocodable
  extend ActiveSupport::Concern

  included do
    has_one :geocoding, dependent: :destroy
    before_save :track_address_changed
    after_commit :assign_geocoding, if: :should_assign_geocoding?
  end

  private

  def track_address_changed
    return if @address_changed

    # we have to do this, we cannot use address_previously_changed? in the after commit block since when a user is
    # commited to the db, a lot of saves are triggered so the previous_changes hash doesn't necessarily contain
    # the address attribute even though it has changed
    @address_changed = address_changed?
  end

  def should_assign_geocoding?
    address.present? && @address_changed
  end

  def assign_geocoding
    RetrieveAndAssignUserGeocodingJob.perform_async(id)
  end
end
