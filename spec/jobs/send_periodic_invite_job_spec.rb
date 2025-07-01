describe SendPeriodicInviteJob do
  describe "#perform" do
    subject do
      described_class.new.perform(invitation.id, format)
    end

    let!(:format) { "email" }
    let!(:organisation) { create(:organisation) }
    let!(:agent) { create(:agent, organisations: [organisation]) }
    let!(:category_configuration) do
      create(:category_configuration,
             organisation: organisation,
             number_of_days_between_periodic_invites: 15,
             number_of_days_before_invitations_expire: nil,
             motif_category: motif_category)
    end
    let!(:motif_category) { create(:motif_category) }
    let!(:follow_up) { create(:follow_up, motif_category: motif_category) }
    let!(:invitation) do
      create(
        :invitation,
        follow_up: follow_up,
        created_at: 15.days.ago,
        expires_at: 1.day.ago,
        organisations: [organisation],
        link: "https://www.rdv-solidarites.fr/prendre_rdv?departement=12&motif_category_short_name=rsa_accompagnement_sociopro&organisation_ids%5B%5D=#{organisation.id}"
      )
    end

    before do
      allow(RdvSolidaritesApi::RetrieveCreneauAvailability).to receive(:call).and_return(
        OpenStruct.new(success?: true, creneau_availability: true)
      )
      allow(Invitations::SaveAndSend).to receive(:call).and_return(OpenStruct.new(success?: true))
    end

    describe "#perform" do
      it "sends invitation" do
        expect(Invitations::SaveAndSend).to receive(:call).once

        subject
      end

      context "when no creneaux are avaialble" do
        before do
          allow(RdvSolidaritesApi::RetrieveCreneauAvailability).to receive(:call).and_return(
            OpenStruct.new(success?: false, creneau_availability: false)
          )
        end

        it "does not send periodic invites" do
          expect(Invitations::SaveAndSend).not_to receive(:call)
          subject
        end
      end

      context "when the invitation is not eligible to be sent again" do
        before { invitation.update!(created_at: 10.days.ago) }

        it "does not send an invitation" do
          expect(Invitations::SaveAndSend).not_to receive(:call)
          subject
        end
      end

      context "caching" do
        let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }

        before do
          allow(RdvSolidaritesApi::RetrieveCreneauAvailability).to receive(:call).and_return(
            OpenStruct.new(success?: true, creneau_availability: true)
          )
          allow(Rails).to receive(:cache).and_return(memory_store)
          Rails.cache.clear
        end

        context "different invites with similar link params" do
          let!(:other_invitation) do
            create(
              :invitation,
              follow_up: other_follow_up,
              created_at: 15.days.ago,
              expires_at: 1.day.ago,
              organisations: [organisation],
              link: "https://www.rdv-solidarites.fr/prendre_rdv?departement=12&motif_category_short_name=rsa_accompagnement_sociopro&organisation_ids%5B%5D=#{organisation.id}"
            )
          end

          let!(:other_follow_up) { create(:follow_up, motif_category: motif_category) }

          it "returns cached reponse" do
            expect(RdvSolidaritesApi::RetrieveCreneauAvailability).to receive(:call).once
            subject

            expect(RdvSolidaritesApi::RetrieveCreneauAvailability).not_to receive(:call)
            described_class.new.perform(other_invitation.id, format)
          end
        end
      end
    end
  end
end
