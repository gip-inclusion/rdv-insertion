module Invitations
  class ComputeLink < BaseService
    def initialize(invitation:)
      @invitation = invitation
    end

    def call
      result.invitation_link = compute_rdv_solidarites_link
    end

    private

    def user = @invitation.user

    def geocoding = user.geocoding

    def geo_attributes
      return {} unless geocoding

      {
        longitude: geocoding.longitude,
        latitude: geocoding.latitude,
        city_code: geocoding.city_code,
        street_ban_id: geocoding.street_ban_id
      }
    end

    def compute_rdv_solidarites_link
      "#{ENV['RDV_SOLIDARITES_URL']}/prendre_rdv?#{link_params.to_query}"
    end

    def link_params
      {
        departement: @invitation.department.number,
        address: address,
        invitation_token: @invitation.rdv_solidarites_token,
        organisation_ids: @invitation.organisations.map(&:rdv_solidarites_organisation_id),
        motif_category_short_name: @invitation.motif_category.short_name
      }
        .merge(@invitation.rdv_solidarites_lieu_id? ? { lieu_id: @invitation.rdv_solidarites_lieu_id } : geo_attributes)
        .merge(
          @invitation.rdv_with_referents? ? { referent_ids: user.referents.map(&:rdv_solidarites_agent_id) } : {}
        )
    end

    def address
      user.address.presence || @invitation.department.name_with_region
    end
  end
end
