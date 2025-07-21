describe OutgoingWebhooks::FranceTravail::DeleteParticipationJob do
  subject do
    described_class.perform_now(
      participation_id: participation.id,
      france_travail_id: participation.france_travail_id,
      user_id: participation.user_id,
      timestamp: now
    )
  end

  let(:participation) { create(:participation) }
  let(:now) { Time.current }

  describe "#perform" do
    before do
      allow(FranceTravailApi::DeleteParticipation).to receive(:call).and_return(OpenStruct.new(success?: true))
      travel_to(now)
    end

    it "calls the delete participation service" do
      subject

      expect(FranceTravailApi::DeleteParticipation).to have_received(:call)
    end

    context "when the user is not found" do
      before do
        allow(User).to receive(:find_by).and_return(nil)
      end

      it "does not call the delete participation service" do
        subject
        expect(FranceTravailApi::DeleteParticipation).not_to have_received(:call)
      end
    end
  end
end
