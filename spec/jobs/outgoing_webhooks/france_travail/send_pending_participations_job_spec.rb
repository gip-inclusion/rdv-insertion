describe OutgoingWebhooks::FranceTravail::SendPendingParticipationsJob do
  subject { described_class.new.perform(user_id: user.id) }

  let!(:department) { create(:department) }
  let!(:organisation) { create(:organisation, department: department) }
  let!(:user) { create(:user, :with_valid_nir, organisations: [organisation]) }
  let!(:follow_up) { create(:follow_up, user: user) }
  let!(:rdv) { create(:rdv, organisation: organisation) }
  let!(:participation) { create(:participation, user: user, rdv: rdv, follow_up: follow_up) }

  before do
    allow(OutgoingWebhooks::FranceTravail::UpsertParticipationJob).to receive(:perform_later)
  end

  context "when participation has no france_travail_id and is eligible" do
    it "enqueues UpsertParticipationJob" do
      expect(OutgoingWebhooks::FranceTravail::UpsertParticipationJob).to receive(:perform_later)
        .with(hash_including(participation_id: participation.id))

      subject
    end
  end

  context "when participation already has a france_travail_id" do
    before { participation.update_column(:france_travail_id, "ft-123") }

    it "does not enqueue UpsertParticipationJob" do
      expect(OutgoingWebhooks::FranceTravail::UpsertParticipationJob).not_to receive(:perform_later)

      subject
    end
  end

  context "when organisation is not eligible" do
    before { organisation.update_column(:organisation_type, "france_travail") }

    it "does not enqueue UpsertParticipationJob" do
      expect(OutgoingWebhooks::FranceTravail::UpsertParticipationJob).not_to receive(:perform_later)

      subject
    end
  end

  context "when department has disable_ft_webhooks" do
    before { department.update_column(:disable_ft_webhooks, true) }

    it "does not enqueue UpsertParticipationJob" do
      expect(OutgoingWebhooks::FranceTravail::UpsertParticipationJob).not_to receive(:perform_later)

      subject
    end
  end
end
