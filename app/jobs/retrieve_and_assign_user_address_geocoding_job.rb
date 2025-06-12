class RetrieveAndAssignUserAddressGeocodingJob < ApplicationJob
  def perform(user_id)
    @user = User.find_by(id: user_id)
    return unless @user

    address_geocoding = AddressGeocoding.find_or_initialize_by(user_id:)
    address_geocoding_params = retrieve_address_geocoding_params

    return address_geocoding.destroy! unless address_geocoding_params

    address_geocoding.assign_attributes(address_geocoding_params)
    address_geocoding.save!
  end

  private

  def retrieve_address_geocoding_params
    call_service!(
      RetrieveAddressGeocodingParams,
      address: @user.address,
      department_number: @user.department.number
    ).geocoding_params
  end
end
