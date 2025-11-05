describe SoftDeleteUserJob do
  subject do
    described_class.new.perform(rdv_solidarites_user_id)
  end

  let!(:rdv_solidarites_user_id) { { id: 1 } }
  let!(:user) { create(:user) }

  describe "#perform" do
    before do
      allow(User).to receive(:find_by)
        .with(rdv_solidarites_user_id: rdv_solidarites_user_id)
        .and_return(user)
      allow(SlackClient).to receive(:send_to_notif_channel)
    end

    it "finds the matching user" do
      expect(User).to receive(:find_by)
        .with(rdv_solidarites_user_id: rdv_solidarites_user_id)
      subject
    end

    it "soft deletes the user" do
      subject
      expect(user.deleted_at).not_to be_nil
      expect(user.uid).to eq(nil)
      expect(user.department_internal_id).to eq(nil)
      expect(user.affiliation_number).to eq(nil)
      expect(user.role).to eq(nil)
    end
  end
end
