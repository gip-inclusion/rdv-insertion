require Rails.root.join("lib/users/transfer_organisation")

describe Users::TransferOrganisation do
  subject do
    service.call
  end

  let(:service) do
    described_class.new(
      source_organisation_id: source_organisation.id,
      target_organisation_id: target_organisation.id,
      source_motif_category_id: motif_category.id
    )
  end
  let!(:agent) { create(:agent) }
  let(:user) { create(:user) }
  let(:source_organisation) { create(:organisation) }
  let(:target_organisation) { create(:organisation) }
  let(:motif_category) { create(:motif_category) }
  let!(:follow_up) { create(:follow_up, user: user, motif_category: motif_category) }

  before do
    source_organisation.users << user
    source_organisation.agents << agent
    allow(Users::SyncWithRdvSolidarites).to receive(:call)
      .with(user: user).and_return(OpenStruct.new(success?: true))
    allow(RdvSolidaritesApi::DeleteUserProfile).to receive(:call)
      .with(
        rdv_solidarites_user_id: user.rdv_solidarites_user_id,
        rdv_solidarites_organisation_id: source_organisation.rdv_solidarites_organisation_id
      ).and_return(OpenStruct.new(success?: true))
  end

  it "calls appropriate services and assigns organisation" do
    expect(Users::Save).to receive(:call)
      .with(user:, organisation: target_organisation).once.and_call_original
    expect(Users::RemoveFromOrganisation).to receive(:call)
      .with(user:, organisation: source_organisation).once.and_call_original

    subject

    expect(user.reload.organisations).to eq([target_organisation])
    expect(service.errors).to be_empty
  end

  context "when assign organisation fails" do
    before do
      allow(Users::Save).to(
        receive(:call).with(user:, organisation: target_organisation).once.and_return(
          OpenStruct.new(success?: false)
        )
      )
    end

    it "does not call remove organisation" do
      expect(Users::RemoveFromOrganisation).not_to receive(:call)

      subject

      expect(service.errors).not_to be_empty
    end
  end
end
