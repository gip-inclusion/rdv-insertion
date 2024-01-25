module Invitations
  class VerifyOrganisationCreneauxAvailability < BaseService
    def initialize(organisation_id:)
      @organisation = Organisation.find(organisation_id)
      Current.agent = @organisation.agents.first
      @invitations_params_without_creneau = []
      @grouped_invitation_params_by_category = []
    end

    def call
      process_invitations
      result.unavailable_params_motifs = process_invitations_params_without_creneau
    end

    private

    def process_invitations
      return unless @organisation.invitations.valid.any?

      grouped_invitations_params.each do |params|
        @invitations_params_without_creneau << params unless creneau_available?(params)
      end
    end

    def grouped_invitations_params
      default_token = @organisation.invitations.valid.first.rdv_solidarites_token
      @organisation.invitations.valid.select("DISTINCT ON (rdv_context_id) *").to_a.map do |invitation|
        map_invitation_params(invitation, default_token)
      end.uniq
    end

    def map_invitation_params(invitation, default_token)
      # We keep uniq relevant params only (for creneaux search in rdvs) to reduce the number of calls to the RDVSP API
      # We take the first invitation token as default token
      # We keep the original invitation_token only if the invitation has a referent_id
      invitation.link_params.symbolize_keys.merge(
        invitation_token:
          invitation.link_params["referent_ids"].nil? ? default_token : invitation.link_params["invitation_token"]
      ).except(:latitude, :longitude, :address)
    end

    def creneau_available?(params)
      RdvSolidaritesApi::RetrieveCreneauAvailability.call(link_params: params).creneau_availability
    end

    def process_invitations_params_without_creneau
      @invitations_params_without_creneau.each do |invitation_params|
        group_invitation_params_by_category(invitation_params)
      end
      @grouped_invitation_params_by_category
    end

    def group_invitation_params_by_category(invitation)
      motif_category_name = MotifCategory.find_by(short_name: invitation[:motif_category_short_name]).name
      city_code = invitation[:city_code]
      referent_ids = invitation[:referent_ids]
      category_params_group = find_or_initialize_category_params_group(motif_category_name)
      unless category_params_group[:city_codes].include?(city_code) || city_code.nil?
        category_params_group[:city_codes] << city_code
      end
      return if category_params_group[:referent_ids].include?(referent_ids) || referent_ids.nil?

      category_params_group[:referent_ids] << referent_ids
    end

    def find_or_initialize_category_params_group(motif_category_name)
      category_params_group = @grouped_invitation_params_by_category.find do |m|
        m[:motif_category_name] == motif_category_name
      end
      return category_params_group if category_params_group.present?

      category_params_group = { motif_category_name: motif_category_name, city_codes: [], referent_ids: [] }
      @grouped_invitation_params_by_category << category_params_group
      category_params_group
    end
  end
end
