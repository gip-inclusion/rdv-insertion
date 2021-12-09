module Invitations
  class ComputeLink < BaseService
    def initialize(organisation:, rdv_solidarites_session:, invitation_token:, applicant:)
      @organisation = organisation
      @rdv_solidarites_session = rdv_solidarites_session
      @invitation_token = invitation_token
      @applicant = applicant
    end

    def call
      retrieve_organisation_motifs!
      check_motifs_presence!
      retrieve_geolocalisation
      result.invitation_link = redirect_link
    end

    private

    def retrieve_organisation_motifs!
      return if retrieve_organisation_motifs.success?

      result.errors += retrieve_organisation_motifs.errors
      fail!
    end

    def retrieve_organisation_motifs
      @retrieve_organisation_motifs ||= RdvSolidaritesApi::RetrieveMotifs.call(
        rdv_solidarites_session: @rdv_solidarites_session,
        organisation: @organisation
      )
    end

    def retrieve_geolocalisation
      @retrieve_geolocalisation ||= RetrieveGeolocalisation.call(
        address: @applicant.address, department: @organisation.department
      )
    end

    def geo_attributes
      return {} unless retrieve_geolocalisation.success?

      {
        longitude: retrieve_geolocalisation.longitude,
        latitude: retrieve_geolocalisation.latitude,
        city_code: retrieve_geolocalisation.city_code,
        street_ban_id: retrieve_geolocalisation.street_ban_id
      }
    end

    def check_motifs_presence!
      return unless motifs.empty?

      fail!("Aucun motif ne correspond aux critères d'invitation. Vérifiez que vous appartenez au bon service.")
    end

    def motifs
      retrieve_organisation_motifs.motifs
    end

    def redirect_link
      "#{ENV['RDV_SOLIDARITES_URL']}/prendre_rdv?#{link_params.to_query}"
    end

    def link_params
      {
        departement: @organisation.department_number,
        address: address,
        invitation_token: @invitation_token,
        organisation_id: @organisation.rdv_solidarites_organisation_id,
        service_id: @organisation.rsa_agents_service_id
      }
        .merge(geo_attributes)
        .merge(motifs.length == 1 ? { motif_id: motifs.first.id } : {})
    end

    def address
      @applicant.address.presence || @organisation.department_name_with_region
    end
  end
end
