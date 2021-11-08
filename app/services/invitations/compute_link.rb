module Invitations
  class ComputeLink < BaseService
    def initialize(organisation:, rdv_solidarites_session:, invitation_token:)
      @organisation = organisation
      @rdv_solidarites_session = rdv_solidarites_session
      @invitation_token = invitation_token
    end

    def call
      retrieve_organisation_motifs!
      check_motifs_presence!
      result.invitation_link = redirect_link + "&invitation_token=#{@invitation_token}"
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

    def check_motifs_presence!
      return unless motifs.empty?

      fail!("Aucun motif ne correspond aux critères d'invitation. Vérifiez que vous appartenez au bon service.")
    end

    def motifs
      retrieve_organisation_motifs.motifs
    end

    def redirect_link
      if motifs.length == 1
        link_with_motif(motifs.first)
      else
        link_without_motif
      end
    end

    def link_with_motif(motif)
      params = {
        search: {
          departement: @organisation.department_number,
          where: @organisation.department_name_with_region,
          motif_name_with_location_type: motif.name_with_location_type,
          # Agents and motifs can be on "Service Social" and not in "Service RSA"
          service: @organisation.rsa_agents_service_id
        }
      }
      "#{ENV['RDV_SOLIDARITES_URL']}/lieux?#{params.to_query}"
    end

    def link_without_motif
      params = { where: @organisation.department_name_with_region }
      "#{ENV['RDV_SOLIDARITES_URL']}/departement/#{@organisation.department_number}/" \
        "#{@organisation.rsa_agents_service_id}?#{params.to_query}"
    end
  end
end
