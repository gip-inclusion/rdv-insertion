describe User::FranceTravailWebhooks, type: :concern do
  describe "#send_pending_participations_to_france_travail" do
    let!(:department) { create(:department) }
    let!(:organisation) { create(:organisation, department: department) }
    let!(:user) { create(:user, organisations: [organisation]) }
    let!(:follow_up) { create(:follow_up, user: user) }
    let!(:rdv) { create(:rdv, organisation: organisation) }
    let!(:participation) { create(:participation, user: user, rdv: rdv, follow_up: follow_up) }

    context "when nir is added to a user with birth_date" do
      before { user.update!(birth_date: "1985-01-01") }

      it "enqueues upsert job for participations without france_travail_id" do
        expect(OutgoingWebhooks::FranceTravail::UpsertParticipationJob).to receive(:perform_later)
          .with(hash_including(participation_id: participation.id))

        user.update!(nir: "185027800608443")
      end
    end

    context "when birth_date is added to a user with nir" do
      before { user.update!(nir: "185027800608443") }

      it "enqueues upsert job for participations without france_travail_id" do
        expect(OutgoingWebhooks::FranceTravail::UpsertParticipationJob).to receive(:perform_later)
          .with(hash_including(participation_id: participation.id))

        user.update!(birth_date: "1985-01-01")
      end
    end

    context "when france_travail_id is added" do
      it "enqueues upsert job for participations without france_travail_id" do
        expect(OutgoingWebhooks::FranceTravail::UpsertParticipationJob).to receive(:perform_later)
          .with(hash_including(participation_id: participation.id))

        user.update!(france_travail_id: "12345678901")
      end
    end

    context "when participation already has a france_travail_id" do
      before { participation.update_column(:france_travail_id, "ft-123") }

      it "does not enqueue upsert job" do
        expect(OutgoingWebhooks::FranceTravail::UpsertParticipationJob).not_to receive(:perform_later)

        user.update!(france_travail_id: "12345678901")
      end
    end

    context "when organisation is not eligible (france_travail type)" do
      before { organisation.update_column(:organisation_type, "france_travail") }

      it "does not enqueue upsert job" do
        expect(OutgoingWebhooks::FranceTravail::UpsertParticipationJob).not_to receive(:perform_later)

        user.update!(france_travail_id: "12345678901")
      end
    end

    context "when department has disable_ft_webhooks" do
      before { department.update_column(:disable_ft_webhooks, true) }

      it "does not enqueue upsert job" do
        expect(OutgoingWebhooks::FranceTravail::UpsertParticipationJob).not_to receive(:perform_later)

        user.update!(france_travail_id: "12345678901")
      end
    end

    context "when user was already retrievable and all participations already transmitted" do
      let!(:user) { create(:user, france_travail_id: "12345678901", organisations: [organisation]) }

      before { participation.update_column(:france_travail_id, "ft-123") }

      it "does not enqueue upsert job" do
        expect(OutgoingWebhooks::FranceTravail::UpsertParticipationJob).not_to receive(:perform_later)

        user.update!(france_travail_id: "98765432109")
      end
    end

    context "when an unrelated attribute changes" do
      it "does not enqueue upsert job" do
        expect(OutgoingWebhooks::FranceTravail::UpsertParticipationJob).not_to receive(:perform_later)

        user.update!(first_name: "Nouveau Prénom")
      end
    end
  end
end
