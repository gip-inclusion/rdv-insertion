describe InboundWebhooks::RdvSolidarites::ProcessUserProfileJob do
  subject do
    described_class.new.perform(data, meta)
  end

  let!(:data) do
    {
      "user" => { "id" => rdv_solidarites_user_id },
      "organisation" => { "id" => rdv_solidarites_organisation_id }
    }.deep_symbolize_keys
  end

  let!(:rdv_solidarites_user_id) { 22 }
  let!(:rdv_solidarites_organisation_id) { 18 }

  let!(:meta) do
    {
      "model" => "UserProfile",
      "event" => "destroyed"
    }.deep_symbolize_keys
  end

  let!(:user) do
    create(:user, rdv_solidarites_user_id: rdv_solidarites_user_id, organisations: [organisation])
  end

  let!(:organisation) { create(:organisation, rdv_solidarites_organisation_id: rdv_solidarites_organisation_id) }

  describe "#call" do
    before do
      allow(SoftDeleteUserJob).to receive(:perform_later)
      allow(NullifyRdvSolidaritesIdJob).to receive(:perform_later)
    end

    it "enqueues a soft delete user job" do
      expect(SoftDeleteUserJob).to receive(:perform_later)
        .with(rdv_solidarites_user_id)
      subject
    end

    context "when the user has more than one organisation" do
      let!(:organisation2) { create(:organisation, department: organisation.department) }
      let!(:user) do
        create(:user, rdv_solidarites_user_id: rdv_solidarites_user_id,
                      organisations: [organisation, organisation2])
      end

      it "removes the organisation from the user" do
        subject
        expect(user.reload.organisations).to eq([organisation2])
      end

      it "does not enqueue a delete user job" do
        expect(SoftDeleteUserJob).not_to receive(:perform_later)
        subject
      end
    end

    context "when the user cannot be found" do
      let!(:user) do
        create(:user, rdv_solidarites_user_id: "some-id", organisations: [organisation])
      end

      it "does not remove the organisation from the user" do
        subject
        expect(user.reload.organisations).to eq([organisation])
      end

      it "does not enqueue a delete user job" do
        expect(SoftDeleteUserJob).not_to receive(:perform_later)
        subject
      end
    end

    context "when the organisation cannot be found" do
      let!(:organisation) do
        create(:organisation, rdv_solidarites_organisation_id: "some-orga")
      end

      it "does not remove the organisation from the user" do
        subject
        expect(user.reload.organisations).to eq([organisation])
      end

      it "does not enqueue a delete user job" do
        expect(SoftDeleteUserJob).not_to receive(:perform_later)
        subject
      end
    end

    context "when there are no user infos in the payload" do
      let!(:data) do
        {
          "organisation" => { "id" => rdv_solidarites_organisation_id }
        }.deep_symbolize_keys
      end

      it "does not remove the organisation from the user" do
        subject
        expect(user.reload.organisations).to eq([organisation])
      end

      it "does not enqueue a delete user job" do
        expect(SoftDeleteUserJob).not_to receive(:perform_later)
        subject
      end
    end

    context "when the event is updated" do
      let!(:meta) do
        {
          "model" => "UserProfile",
          "event" => "updated"
        }.deep_symbolize_keys
      end

      context "when the user does not belong to the org" do
        let!(:other_org) { create(:organisation, department: organisation.department) }
        let!(:user) do
          create(:user, rdv_solidarites_user_id: rdv_solidarites_user_id, organisations: [other_org], department: organisation.department)
        end

        it "adds the user to the org" do
          subject
          expect(user.reload.organisations.ids.sort).to eq([other_org.id, organisation.id].sort)
        end

        it "does not enqueue a delete user job" do
          expect(SoftDeleteUserJob).not_to receive(:perform_later)
          subject
        end
      end

      context "when the user already belongs to org" do
        it "does not do anything" do
          expect(SoftDeleteUserJob).not_to receive(:perform_later)
          subject
          expect(user.reload.organisations.ids).to eq([organisation.id])
        end
      end
    end

    context "when the event is created" do
      let!(:meta) do
        {
          "model" => "UserProfile",
          "event" => "created"
        }.deep_symbolize_keys
      end

      context "when the user does not belong to the org" do
        let!(:other_org) { create(:organisation, department: organisation.department) }
        let!(:user) do
          create(:user, rdv_solidarites_user_id: rdv_solidarites_user_id, organisations: [other_org], department: organisation.department)
        end

        it "adds the user to the org" do
          subject
          expect(user.reload.organisations.ids.sort).to eq([other_org.id, organisation.id].sort)
        end

        it "does not enqueue a delete user job" do
          expect(SoftDeleteUserJob).not_to receive(:perform_later)
          subject
        end
      end

      context "when the user already belongs to org" do
        it "does not do anything" do
          expect(SoftDeleteUserJob).not_to receive(:perform_later)
          subject
          expect(user.reload.organisations.ids).to eq([organisation.id])
        end
      end
    end

    context "when the webhook reason is rgpd" do
      let!(:meta) do
        {
          "model" => "UserProfile",
          "event" => "destroyed",
          "webhook_reason" => "rgpd"
        }.deep_symbolize_keys
      end

      it "enqueues a nullify rdv_solidarites_id job" do
        expect(NullifyRdvSolidaritesIdJob).to receive(:perform_later)
          .with("User", user.id)
        subject
      end

      context "when the rdv_solidarites_id is nil" do
        let!(:user) do
          create(:user, rdv_solidarites_user_id: nil, organisations: [organisation])
        end

        it "does not enqueue any job" do
          expect(NullifyRdvSolidaritesIdJob).not_to receive(:perform_later)
          expect(SoftDeleteUserJob).not_to receive(:perform_later)
          subject
        end
      end
    end
  end
end
