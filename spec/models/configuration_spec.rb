describe Configuration do
  describe "delays validation" do
    context "number_of_days_to_accept_invitation is inferior or equal to number_of_days_before_action_required" do
      let(:configuration) do
        build(:configuration, number_of_days_to_accept_invitation: 3, number_of_days_before_action_required: 5)
      end

      it { expect(configuration).to be_valid }
    end

    context "number_of_days_to_accept_invitation is superior to number_of_days_before_action_required" do
      let(:configuration) do
        build(:configuration, number_of_days_to_accept_invitation: 3, number_of_days_before_action_required: 2)
      end

      it "adds errors" do
        expect(configuration).not_to be_valid
        expect(configuration.errors.full_messages.to_sentence)
          .to include("Le délai de prise de rendez-vous communiqué au bénéficiaire ne peut pas être inférieur")
      end
    end
  end
end
