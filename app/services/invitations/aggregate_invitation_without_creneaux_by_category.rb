module Invitations
  class AggregateInvitationWithoutCreneauxByCategory < BaseService
    def initialize(organisation_id:)
      @organisation = Organisation.find(organisation_id)
      @invitations_params_without_creneau = []
      @grouped_invitation_params_by_category = []
    end

    def call
      # On prend le premier agent de l'organisation pour les appels à l'API RDVSP
      @organisation.agents.first.with_rdv_solidarites_session do
        aggregate_invitations_without_creneaux
        result.grouped_invitation_params_by_category = group_invitations_without_creneaux_by_category
      end
    end

    private

    def aggregate_invitations_without_creneaux
      return if organisation_valid_invitations.empty?

      invitations_params.each do |params|
        @invitations_params_without_creneau << params unless creneau_available?(params)
      end
    end

    def invitations_params
      organisation_valid_invitations.includes(:user).select("DISTINCT ON (follow_up_id) *").to_a.map do |invitation|
        invitation.link_params.merge(post_code: invitation.user.parsed_post_code).symbolize_keys
      end
    end

    def organisation_valid_invitations
      @organisation.invitations.expireable.valid
    end

    def creneau_available?(params)
      RdvSolidaritesApi::RetrieveCreneauAvailability.call(link_params: params).creneau_availability
    end

    def group_invitations_without_creneaux_by_category
      @invitations_params_without_creneau.each do |invitation_params|
        group_invitation_params_by_category(invitation_params)
      end
      @grouped_invitation_params_by_category
    end

    def group_invitation_params_by_category(invitation_params)
      motif_category = MotifCategory.find_by(short_name: invitation_params[:motif_category_short_name])

      post_code = invitation_params[:post_code]
      referent_ids = invitation_params[:referent_ids]
      category_params_group = find_or_initialize_category_params_group(motif_category)
      category_params_group[:invitations_counter] += 1
      category_params_group[:post_codes].add(post_code) if post_code.present?
      category_params_group[:referent_ids].merge(referent_ids) if referent_ids.present?
    end

    def find_or_initialize_category_params_group(motif_category)
      category_params_group = @grouped_invitation_params_by_category.find do |m|
        m[:motif_category_name] == motif_category.name
      end
      return category_params_group if category_params_group.present?

      category_params_group = {
        motif_category_name: motif_category.name,
        motif_category_id: motif_category.id,
        post_codes: Set.new,
        referent_ids: Set.new,
        invitations_counter: 0
      }
      @grouped_invitation_params_by_category << category_params_group
      category_params_group
    end
  end
end
