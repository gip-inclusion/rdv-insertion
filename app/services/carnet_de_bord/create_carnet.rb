class CarnetDeBord::CreateCarnet < BaseService
  def initialize(applicant:, agent:, department:)
    @applicant = applicant
    @agent = agent
    @department = department
  end

  def call
    verify_deploiement_id!
    verify_carnet_is_not_created!
    Applicant.transaction do
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
    return if @applicant.carnet_de_bord_carnet_id.blank?

    fail!("le carnet existe déjà pour la personne #{@applicant.id}")
  end

  def assign_carnet_de_bord_carnet_id
    @applicant.carnet_de_bord_carnet_id = parsed_response_body["notebookId"]
    save_record!(@applicant)
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
        nir: @applicant.nir,
        externalId: @applicant.department_internal_id,
        firstname: @applicant.first_name,
        lastname: @applicant.last_name,
        dateOfBirth: @applicant.birth_date,
        mobileNumber: @applicant.phone_number,
        email: @applicant.email,
        cafNumber: @applicant.affiliation_number
      }.merge(address_attributes).compact
    }
  end

  def address_attributes
    return {} if @applicant.address.blank?
    return {} if retrieve_geolocalisation.failure?

    {
      address1: retrieve_geolocalisation.name,
      postalCode: retrieve_geolocalisation.postcode,
      city: retrieve_geolocalisation.city
    }
  end

  def retrieve_geolocalisation
    @retrieve_geolocalisation ||= RetrieveGeolocalisation.call(
      address: @applicant.address, department_number: @department.number
    )
  end
end
