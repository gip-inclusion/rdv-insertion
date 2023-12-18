describe NullifyRdvSolidaritesIdJob do
  subject do
    described_class.new.perform(class_name, id)
  end

  describe "#perform" do
    let!(:user) { create(:user, rdv_solidarites_user_id: 17) }
    let!(:class_name) { "User" }
    let!(:id) { user.id }

    it "nullifies the rdv_solidarites_id" do
      subject
      expect(user.reload.rdv_solidarites_user_id).to be_nil
    end

    context "when the resource is a rdv" do
      let!(:class_name) { "Rdv" }
      let!(:rdv) { create(:rdv, rdv_solidarites_rdv_id: 17) }
      let!(:id) { rdv.id }

      it "nullifies the rdv_solidarites_id" do
        subject
        expect(rdv.reload.rdv_solidarites_rdv_id).to be_nil
      end
    end

    context "when the resource is deleted" do
      before { user.update!(deleted_at: Time.zone.now) }

      it "does not nullify the rdv_solidarites_id" do
        subject
        expect(user.reload.rdv_solidarites_user_id).to eq(17)
      end
    end

    context "when the resource cannot be found" do
      let!(:id) { 17 }

      it "does not nullify the rdv_solidarites_id" do
        subject
        expect(user.reload.rdv_solidarites_user_id).to eq(17)
      end
    end
  end
end
