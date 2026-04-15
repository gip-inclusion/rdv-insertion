describe User::FranceTravailWebhooks, type: :concern do
  describe "#send_pending_participations_to_france_travail" do
    let!(:department) { create(:department) }
    let!(:organisation) { create(:organisation, department: department) }
    let!(:user) { create(:user, organisations: [organisation]) }

    context "when nir is added to a user with birth_date" do
      before { user.update!(birth_date: "1985-01-01") }

      it "enqueues SendPendingParticipationsJob" do
        expect(OutgoingWebhooks::FranceTravail::SendPendingParticipationsJob).to receive(:perform_later)
          .with(user_id: user.id)

        user.update!(nir: "185027800608443")
      end
    end

    context "when birth_date is added to a user with nir" do
      before { user.update!(nir: "185027800608443") }

      it "enqueues SendPendingParticipationsJob" do
        expect(OutgoingWebhooks::FranceTravail::SendPendingParticipationsJob).to receive(:perform_later)
          .with(user_id: user.id)

        user.update!(birth_date: "1985-01-01")
      end
    end

    context "when france_travail_id is added" do
      it "enqueues SendPendingParticipationsJob" do
        expect(OutgoingWebhooks::FranceTravail::SendPendingParticipationsJob).to receive(:perform_later)
          .with(user_id: user.id)

        user.update!(france_travail_id: "12345678901")
      end
    end

    context "when an unrelated attribute changes" do
      it "does not enqueue SendPendingParticipationsJob" do
        expect(OutgoingWebhooks::FranceTravail::SendPendingParticipationsJob).not_to receive(:perform_later)

        user.update!(first_name: "Nouveau Prénom")
      end
    end
  end
end
