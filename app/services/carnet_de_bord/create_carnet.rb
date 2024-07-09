class CarnetDeBord::CreateCarnet < BaseService
  def initialize(user:, agent:, department:)
    @user = user
    @agent = agent
    @department = department
  end

  def call
    verify_deploiement_id!
    verify_carnet_is_not_created!
    User.transaction do
      create_carnet!
      assign_carnet_de_bord_carnet_id
    end
  end

  private

  def verify_deploiement_id!
    return if @department.carnet_de_bord_deploiement_id?

    fail!("le département #{@department.number} n'a pas d'ID de déploiement CdB")
  end

  def verify_carnet_is_not_created!
    return if @user.carnet_de_bord_carnet_id.blank?

    fail!("le carnet existe déjà pour la personne #{@user.id}")
  end

  def assign_carnet_de_bord_carnet_id
    @user.carnet_de_bord_carnet_id = parsed_response_body["notebookId"]
    save_record!(@user)
  end

  def parsed_response_body
    JSON.parse(create_carnet.body)
  end

  def create_carnet!
    return if create_carnet.success?

    fail!("Erreur en créant le carnet: #{parsed_response_body['message']} - #{create_carnet.status}")
  end

  def create_carnet
    @create_carnet ||= CarnetDeBordClient.create_carnet(cdb_payload)
  end

  def cdb_payload
    {
      rdviUserEmail: @agent.email,
      deploymentId: @department.carnet_de_bord_deploiement_id,
      notebook: {
        nir: @user.nir,
        externalId: @user.department_internal_id,
        firstname: @user.first_name,
        lastname: @user.last_name,
        dateOfBirth: @user.birth_date,
        mobileNumber: @user.phone_number,
        email: @user.email,
        cafNumber: @user.affiliation_number
      }.merge(address_attributes).compact
    }
  end

  def address_attributes
    return {} if @user.address.blank?
    # since carnet creation is used very rarely, we call the RetrieveGeocoding service directrly instead of retrieving
    # the geocoding record to be sure we have a geocoding up to date (since the record is saved asynchronously)
    return {} if retrieve_address_geocoding_params.failure?

    address_geocoding = AddressGeocoding.new(retrieve_address_geocoding_params.geocoding_params)

    {
      address1: address_geocoding.street_address,
      postalCode: address_geocoding.post_code,
      city: address_geocoding.city
    }
  end

  def retrieve_address_geocoding_params
    @retrieve_address_geocoding_params ||= RetrieveAddressGeocodingParams.call(
      address: @user.address, department_number: @department.number
    )
  end
end
