describe OutgoingWebhooks::FranceTravail::CancelParticipationJob do
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
      allow(FranceTravailApi::CancelParticipation).to receive(:call).and_return(OpenStruct.new(success?: true))
      travel_to(now)
    end

    it "calls the delete participation service" do
      subject

      expect(FranceTravailApi::CancelParticipation).to have_received(:call)
    end

    context "when the user is not found" do
      before do
        allow(User).to receive(:find_by).and_return(nil)
      end

      it "does not call the delete participation service" do
        subject
        expect(FranceTravailApi::CancelParticipation).not_to have_received(:call)
      end
    end

    context "when the service fails with regular error" do
      before do
        allow(FranceTravailApi::CancelParticipation).to receive(:call)
          .and_return(OpenStruct.new(success?: false, failure?: true, errors: ["Some error"], error_type: nil))
      end

      it "raises a FailedServiceError" do
        expect { subject }.to raise_error(ApplicationJob::FailedServiceError)
      end
    end

    context "when the service fails with participation_not_found error_type" do
      before do
        allow(FranceTravailApi::CancelParticipation).to receive(:call)
          .and_return(OpenStruct.new(
                        success?: false,
                        failure?: true,
                        errors: ["L'ID France Travail de la participation n'existe plus"],
                        error_type: :participation_not_found
                      ))
      end

      it "does not raise an error" do
        expect { subject }.not_to raise_error
      end
    end
  end
end
