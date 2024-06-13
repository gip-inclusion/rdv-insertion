class AssignGeocodingJob < ApplicationJob
  def perform(user_id)
    @user = User.find_by(id: user_id)
    return unless @user

    geocoding = Geocoding.find_or_initialize_by(user_id:)
    geocoding_params = retrieve_geocoding_params

    return geocoding.destroy! unless geocoding_params

    geocoding.assign_attributes(geocoding_params)
    geocoding.save!
  end

  private

  def retrieve_geocoding_params
    if @user.current_department
      retrieve_geocoding_params_for(address: @user.address, department_number: @user.current_department.number)
    else
      @user.departments.find do |department|
        retrieve_geocoding_params_for(address: @user.address, department_number: department.number)
      end
    end
  end

  def retrieve_geocoding_params_for(address:, department_number:)
    call_service!(
      RetrieveGeocoding,
      address:,
      department_number:
    ).geocoding_params
  end
end
