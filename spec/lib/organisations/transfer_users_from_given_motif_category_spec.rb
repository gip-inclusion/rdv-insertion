require Rails.root.join("lib/organisations/transfer_users_from_given_motif_category")

describe Organisations::TransferUsersFromGivenMotifCategory do
  describe "#call" do
    subject { transfer.call }

    let(:source_organisation) { create(:organisation) }
    let(:target_organisation) { create(:organisation) }
    let(:motif_category) { create(:motif_category) }
    let(:user) { create(:user) }
    let(:rdv) { create(:rdv, organisation: source_organisation) }
    let(:follow_up) { create(:follow_up, user:, motif_category:) }
    let!(:participation) { create(:participation, rdv:, user:, follow_up:) }

    let!(:source_category_configuration) do
      create(:category_configuration, organisation: source_organisation, motif_category: motif_category)
    end

    let!(:target_category_configuration) do
      create(:category_configuration, organisation: target_organisation, motif_category: motif_category)
    end

    let(:transfer) do
      described_class.new(
        source_organisation_id: source_organisation.id,
        target_organisation_id: target_organisation.id,
        motif_category_id: motif_category.id
      )
    end

    before do
      create(:users_organisation, organisation: source_organisation, user:)
    end

    it "transfers users from source to target organisation" do
      transfer.call

      expect(UsersOrganisation.where(user:, organisation: source_organisation)).to be_empty
      expect(UsersOrganisation.where(user:, organisation: target_organisation)).not_to be_empty
      expect(rdv.reload.organisation).to eq(target_organisation)
      expect(CategoryConfiguration.find_by(organisation: source_organisation, motif_category:)).to be_nil
      expect(target_organisation.users).to include(user)
      expect(source_organisation.users).not_to include(user)
    end
  end
end
