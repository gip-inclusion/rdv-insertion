describe Configuration do
  describe "delays validation" do
    context "number_of_days_before_action_required is superior to 3" do
      let(:configuration) do
        build(:configuration, organisation: create(:organisation), number_of_days_before_action_required: 5)
      end

      it { expect(configuration).to be_valid }
    end

    context "number_of_days_before_action_required is inferior to 3" do
      let(:configuration) do
        build(:configuration, organisation: create(:organisation), number_of_days_before_action_required: 2)
      end

      it "adds errors" do
        expect(configuration).not_to be_valid
        expect(configuration.errors.full_messages.to_sentence)
          .to include("Le délai d'expiration de l'invtation doit être supérieur à 3 jours")
      end
    end
  end

  describe "invitation formats validity" do
    context "invitation formats are valid" do
      let(:configuration) do
        build(:configuration, organisation: create(:organisation), invitation_formats: %w[sms email postal])
      end

      it { expect(configuration).to be_valid }
    end

    context "invitation formats are not valid" do
      let(:configuration) do
        build(:configuration, organisation: create(:organisation), invitation_formats: %w[sms test])
      end

      it "adds errors" do
        expect(configuration).not_to be_valid
        expect(configuration.errors.full_messages.to_sentence)
          .to include("Les formats d'invitation ne peuvent être que : sms, email, postal")
      end
    end
  end
end
