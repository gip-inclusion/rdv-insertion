describe Invitations::AggregateInvitationWithoutCreneaux, type: :service do
  subject do
    described_class.call(organisation_id: organisation.id)
  end

  include_context "with all existing categories"

  let!(:organisation) { create(:organisation, agents: [create(:agent)]) }
  let!(:invitation_with_no_creneau1) do
    create(:invitation, organisations: [organisation], link: "http://rdv-solidarites-test.fr?referent_ids%5B%5D=17")
  end
  let!(:invitation_with_no_creneau2) do
    create(:invitation, organisations: [organisation], link: "http://rdv-solidarites-test.fr?referent_ids%5B%5D=18")
  end
  let!(:invitation_with_no_creneau_expired) do
    create(:invitation, organisations: [organisation], expires_at: 1.day.ago)
  end
  let!(:invitation_with_no_creneau_not_expirable) do
    create(:invitation, organisations: [organisation], expires_at: nil)
  end
  let!(:invitation_with_creneau) { create(:invitation, organisations: [organisation]) }

  describe "#call" do
    before do
      allow(RdvSolidaritesApi::RetrieveCreneauAvailability).to receive(:call)
        .and_return(OpenStruct.new(creneau_availability: false, success?: true))
      allow(RdvSolidaritesApi::RetrieveCreneauAvailability).to receive(:call)
        .with(link_params: invitation_with_creneau.link_params)
        .and_return(OpenStruct.new(creneau_availability: true, success?: true))
    end

    it "is a success" do
      is_a_success
    end

    context "with results" do
      let!(:result) { subject }

      it "returns invitations without available creneaux" do
        expected_invitations = [
          invitation_with_no_creneau1,
          invitation_with_no_creneau2
        ]

        expect(result.invitations_without_creneaux).to match_array(expected_invitations)
      end

      it "does not include invitations with available creneaux" do
        expect(result.invitations_without_creneaux).not_to include(invitation_with_creneau)
      end

      it "does not include non-expireable invitations" do
        expect(result.invitations_without_creneaux).not_to include(invitation_with_no_creneau_not_expirable)
      end

      it "does not include expired invitations" do
        expect(result.invitations_without_creneaux).not_to include(invitation_with_no_creneau_expired)
      end
    end
  end
end
