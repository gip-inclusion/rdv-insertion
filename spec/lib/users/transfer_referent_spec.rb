require Rails.root.join("lib/users/transfer_referent")

describe Users::TransferReferent do
  subject { described_class.new(source_referent_id: source_referent.id, target_referent_id: target_referent.id).call }

  let(:user) { create(:user) }
  let(:source_referent) { create(:agent) }
  let(:target_referent) { create(:agent) }

  before do
    source_referent.users << user
    stub_rdv_solidarites_assign_referent(
      user.rdv_solidarites_user_id,
      target_referent.rdv_solidarites_agent_id
    )
    stub_rdv_solidarites_assign_referent(
      user.rdv_solidarites_user_id,
      source_referent.rdv_solidarites_agent_id
    )
  end

  it "calls appropriate services and assigns referent" do
    expect(Users::AssignReferent).to receive(:call).with(user:, agent: target_referent).once.and_call_original
    expect(Users::RemoveReferent).to receive(:call).with(user:, agent: source_referent).once.and_call_original

    subject

    expect(user.reload.referents).to eq([target_referent])
  end

  context "when assign referent fails" do
    before do
      allow(Users::AssignReferent).to(
        receive(:call).with(user:, agent: target_referent).once.and_return(
          OpenStruct.new(success?: false)
        )
      )
    end

    it "does not call remove referent" do
      expect(Users::RemoveReferent).not_to receive(:call)

      subject
    end
  end
end
