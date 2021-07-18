module Invitations
  class ComputeLink < BaseService
    def initialize(department:, rdv_solidarites_session:, invitation_token:)
      @department = department
      @rdv_solidarites_session = rdv_solidarites_session
      @invitation_token = invitation_token
    end

    def call
      retrieve_organisation_motifs!
      result.invitation_link = redirect_link + "&invitation_token=#{@invitation_token}"
    end

    private

    def retrieve_organisation_motifs!
      return if rdv_solidarites_response.success?

      fail!("erreur RDV-Solidarités: #{rdv_solidarites_response_body['errors']}")
    end

    def redirect_link
      if motifs.one?
        link_with_motif(motifs.first)
      else
        link_without_motif
      end
    end

    def link_with_motif(motif)
      params = {
        search: {
          departement: @department.number,
          where: @department.name_with_region,
          motif_name_with_location_type: "#{motif['name']}-#{motif['location_type']}",
          service: ENV['RDV_SOLIDARITES_RSA_SERVICE_ID']
        }
      }
      "#{ENV['RDV_SOLIDARITES_URL']}/lieux?#{params.to_query}"
    end

    def link_without_motif
      params = { where: @department.name_with_region }
      "#{ENV['RDV_SOLIDARITES_URL']}/departement/#{@department.number}/#{ENV['RDV_SOLIDARITES_RSA_SERVICE_ID']}" \
      "?#{params.to_query}"
    end

    def motifs
      rdv_solidarites_response_body['motifs']
    end

    def rdv_solidarites_response_body
      JSON.parse(rdv_solidarites_response.body)
    end

    def rdv_solidarites_response
      @rdv_solidarites_response ||= rdv_solidarites_client.get_motifs(@department.rdv_solidarites_organisation_id)
    end

    def rdv_solidarites_client
      @rdv_solidarites_client ||= RdvSolidaritesClient.new(@rdv_solidarites_session)
    end
  end
end
