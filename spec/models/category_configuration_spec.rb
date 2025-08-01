describe CategoryConfiguration do
  describe "phone number validation" do
    context "4 digits is ok" do
      let(:category_configuration) do
        build(:category_configuration, organisation: create(:organisation), phone_number: "3630")
      end

      it { expect(category_configuration).to be_valid }
    end
  end

  describe "associations" do
    context "category_configuration is destroyed" do
      let(:category_configuration) { create(:category_configuration) }
      let!(:creneau_availability) { create(:creneau_availability, category_configuration: category_configuration) }

      it "destroys creneaux_availability" do
        expect { category_configuration.destroy }.to change(CreneauAvailability, :count).by(-1)
      end
    end
  end

  describe "delays validation" do
    context "number_of_days_before_invitations_expire is superior to 3" do
      let(:category_configuration) do
        build(:category_configuration, organisation: create(:organisation), number_of_days_before_invitations_expire: 5)
      end

      it { expect(category_configuration).to be_valid }
    end

    context "number_of_days_before_invitations_expire is inferior to 3" do
      let(:category_configuration) do
        build(:category_configuration, organisation: create(:organisation), number_of_days_before_invitations_expire: 2)
      end

      it "adds errors" do
        expect(category_configuration).not_to be_valid
        expect(category_configuration.errors.full_messages.to_sentence)
          .to include("Le délai d'expiration de l'invitation doit être supérieur à 3 jours")
      end
    end
  end

  describe "invitation formats validity" do
    context "invitation formats are valid" do
      let(:category_configuration) do
        build(:category_configuration, organisation: create(:organisation), invitation_formats: %w[sms email postal])
      end

      it { expect(category_configuration).to be_valid }
    end

    context "invitation formats are not valid" do
      let(:category_configuration) do
        build(:category_configuration, organisation: create(:organisation), invitation_formats: %w[sms test])
      end

      it "adds errors" do
        expect(category_configuration).not_to be_valid
        expect(category_configuration.errors.full_messages.to_sentence)
          .to include("Les formats d'invitation ne peuvent être que : sms, email, postal")
      end
    end
  end

  describe "organisation already attached to motif_category" do
    context "a category_configuration with the given motif_category already exists for the organisation" do
      let!(:organisation) { create(:organisation) }
      let!(:motif_category) { create(:motif_category) }
      let!(:category_configuration) do
        create(:category_configuration, organisation: organisation, motif_category: motif_category)
      end
      let(:new_configuration) do
        build(:category_configuration, organisation: organisation, motif_category: motif_category)
      end

      it "adds errors" do
        expect(new_configuration).not_to be_valid
        expect(new_configuration.errors.full_messages.to_sentence)
          .to include("Organisation a déjà une category_configuration pour cette catégorie de motif")
      end
    end
  end
end
