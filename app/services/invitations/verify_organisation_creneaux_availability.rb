module Invitations
  class VerifyOrganisationCreneauxAvailability < BaseService
    def initialize(organisation_id:)
      @organisation = Organisation.find(organisation_id)
      # Quid de l'agent connecté pour la vérication des créneaux disponibles ? utiliser un super agent ? comme proposé
      # ici : https://github.com/betagouv/rdv-insertion/pull/1449/commits/2526b569660d32ad1d15fcdc7b8e4c596125f8b4
      Current.agent = @organisation.agents.first
      @invitations_params_without_creneau = []
      @unavailable_motifs = []
    end

    def call
      process_invitations
      process_invitations_params_without_creneau
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
      @organisation.invitations.valid.map do |invitation|
        map_invitation_params(invitation, default_token)
      end.uniq
    end

    def map_invitation_params(invitation, default_token)
      # We map relevant params only (for creneaux search in rdvs) is done to reduce the number of calls to the RDVSP API
      # The uniq filter on this mapping reduce the number of average calls to the API by /3
      # We take the first invitation token as default token
      # We keep the original invitation_token only if the invitation has a referent_id
      token = invitation.link_params["referent_ids"].nil? ? default_token : invitation.link_params["invitation_token"]
      {
        organisation_ids: invitation.link_params["organisation_ids"],
        referent_ids: invitation.link_params["referent_ids"],
        motif_category_short_name: invitation.link_params["motif_category_short_name"],
        departement: invitation.link_params["departement"],
        city_code: invitation.link_params["city_code"],
        street_ban_id: invitation.link_params["street_ban_id"],
        invitation_token: token
      }
    end

    def creneau_available?(params)
      RdvSolidaritesApi::RetrieveCreneauAvailability.call(link_params: params).creneau_availability
    end

    def process_invitations_params_without_creneau
      @invitations_params_without_creneau.each do |invitation_params|
        add_invitation_motif_to_unavailable_motifs(invitation_params)
      end

      @unavailable_motifs
    end

    def add_invitation_motif_to_unavailable_motifs(invitation)
      motif_name = MotifCategory.find_by(short_name: invitation[:motif_category_short_name]).name
      city_code = invitation[:city_code]
      referent_ids = invitation[:referent_ids]
      motif_hash = find_or_initialize_motif_hash(motif_name)
      motif_hash[:city_codes] << city_code unless motif_hash[:city_codes].include?(city_code) || city_code.nil?
      return if motif_hash[:referent_ids].include?(referent_ids) || referent_ids.nil?

      motif_hash[:referent_ids] << referent_ids
    end

    def find_or_initialize_motif_hash(motif_name)
      motif_hash = @unavailable_motifs.find { |m| m[:motif_name] == motif_name }
      return motif_hash if motif_hash.present?

      motif_hash = { motif_name: motif_name, city_codes: [], referent_ids: [] }
      @unavailable_motifs << motif_hash
      motif_hash
    end
  end
end
