module Invitations
  class AggregateInvitationWithoutCreneaux < BaseService
    def initialize(organisation_id:)
      @organisation = Organisation.find(organisation_id)
      @invitations_without_creneaux = []
    end

    def call
      # On prend le premier agent de l'organisation pour les appels à l'API RDVSP
      @organisation.agents.first.with_rdv_solidarites_session do
        aggregate_invitations_without_creneaux
      end
      result.invitations_without_creneaux = @invitations_without_creneaux
    end

    private

    def aggregate_invitations_without_creneaux
      # DISTINCT ON (follow_up_id) guarantees to not have multiple invitations for each format
      organisation_valid_invitations.select("DISTINCT ON (follow_up_id) *").to_a.each do |invitation|
        next if creneau_available?(invitation.link_params)

        @invitations_without_creneaux << invitation
      end
    end

    def organisation_valid_invitations
      @organisation.invitations.expireable.valid
    end

    def creneau_available?(link_params)
      RdvSolidaritesApi::RetrieveCreneauAvailability.call(link_params: link_params).creneau_availability
    end
  end
end
