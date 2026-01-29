class RetrieveAndAssignUserAddressGeocodingJob < ApplicationJob
  include LockedJobs

  def self.lock_key(user_id)
    "#{base_lock_key}:#{user_id}"
  end

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
    if matching_department
      retrieve_address_geocoding_params_for(address: @user.address, department_number: matching_department.number)
    else
      @user.departments.find do |department|
        geo_params = retrieve_address_geocoding_params_for(address: @user.address, department_number: department.number)
        break geo_params if geo_params
      end
    end
  end

  def retrieve_address_geocoding_params_for(address:, department_number:)
    call_service!(
      RetrieveAddressGeocodingParams,
      address:,
      department_number:
    ).geocoding_params
  end

  def matching_department
    @user.current_department || @user.address_department
  end
end
