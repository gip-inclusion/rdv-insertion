describe Organisations::RgpdCleanup, type: :service do
  let(:organisation) { create(:organisation, data_retention_duration: 24) }
  let(:service) { described_class.new(organisation: organisation) }

  describe "#call" do
    it "calls all cleanup methods" do
      allow(service).to receive(:process_inactive_users)
      allow(service).to receive(:destroy_useless_rdvs)
      allow(service).to receive(:destroy_useless_notifications)

      service.call

      expect(service).to have_received(:process_inactive_users)
      expect(service).to have_received(:destroy_useless_rdvs)
      expect(service).to have_received(:destroy_useless_notifications)
    end
  end

  describe "#process_inactive_users" do
    let(:old_date) { 25.months.ago }
    let(:recent_date) { 1.month.ago }

    let!(:inactive_user) { create(:user, created_at: old_date) }
    let!(:active_user) { create(:user, created_at: recent_date) }
    let!(:inactive_user_organisation) do
      create(:users_organisation, user: inactive_user, organisation: organisation, created_at: old_date)
    end
    let!(:active_user_organisation) do
      create(:users_organisation, user: active_user, organisation: organisation, created_at: recent_date)
    end

    context "when user is only in current organisation" do
      it "destroys the user completely" do
        allow(MattermostClient).to receive(:send_to_notif_channel)

        expect { service.call }.to change(User, :count).by(-1)
        expect(User.exists?(inactive_user.id)).to be false
        expect(User.exists?(active_user.id)).to be true
      end

      it "sends deletion notification" do
        allow(MattermostClient).to receive(:send_to_notif_channel)

        service.call

        expect(MattermostClient).to have_received(:send_to_notif_channel).with(
          match(/Les usagers suivants ont été supprimés pour inactivité dans l'organisation #{organisation.name}/)
        )
      end
    end

    context "when user is in multiple organisations" do
      let(:other_organisation) { create(:organisation, data_retention_duration: 24) }
      let!(:inactive_user_organisation_other_organisation) do
        create(:users_organisation, user: inactive_user, organisation: other_organisation, created_at: old_date)
      end

      it "removes user from current organisation only" do
        allow(MattermostClient).to receive(:send_to_notif_channel)

        expect { service.call }.not_to change(User, :count)
        expect(User.exists?(inactive_user.id)).to be true
        expect(inactive_user.reload.users_organisations.where(organisation: organisation)).to be_empty
        expect(inactive_user.users_organisations.where(organisation: other_organisation)).to be_present
      end

      it "sends removal notification" do
        allow(MattermostClient).to receive(:send_to_notif_channel)

        service.call

        expect(MattermostClient).to have_received(:send_to_notif_channel).with(
          match(/Les usagers suivants ont été retirés de l'organisation #{organisation.name} pour inactivité/)
        )
      end
    end
  end

  describe "#destroy_useless_rdvs" do
    let(:old_date) { 25.months.ago }
    let(:recent_date) { 1.month.ago }

    let!(:useless_rdv) do
      rdv = create(:rdv, organisation: organisation, created_at: old_date)
      rdv.participations.destroy_all
      rdv
    end

    let!(:recent_rdv) do
      rdv = create(:rdv, organisation: organisation, created_at: recent_date)
      rdv.participations.destroy_all
      rdv
    end

    it "destroys old rdvs without participations" do
      expect { service.call }.to change(Rdv, :count).by(-1)
      expect(Rdv.exists?(useless_rdv.id)).to be false
      expect(Rdv.exists?(recent_rdv.id)).to be true
    end

    it "sends notification when rdvs are deleted" do
      allow(MattermostClient).to receive(:send_to_notif_channel)
      service.call

      expect(MattermostClient).to have_received(:send_to_notif_channel).with(
        match(/Les rdvs suivants ont été supprimés automatiquement pour l'organisation #{organisation.name}/)
      )
    end
  end

  describe "#destroy_useless_notifications" do
    let(:old_date) { 25.months.ago }
    let(:recent_date) { 1.month.ago }

    let!(:useless_notification) do
      rdv = create(:rdv, organisation: organisation)
      participation = create(:participation, rdv: rdv)
      notification = create(:notification,
                            participation: participation,
                            rdv_solidarites_rdv_id: rdv.rdv_solidarites_rdv_id,
                            created_at: old_date)
      notification.update_column(:participation_id, nil)
      notification
    end

    let!(:recent_notification) do
      rdv = create(:rdv, organisation: organisation)
      participation = create(:participation, rdv: rdv)
      notification = create(:notification,
                            participation: participation,
                            rdv_solidarites_rdv_id: rdv.rdv_solidarites_rdv_id,
                            created_at: recent_date)
      notification.update_column(:participation_id, nil)
      notification
    end

    it "destroys old notifications without participations" do
      expect { service.call }.to change(Notification, :count).by(-1)
      expect(Notification.exists?(useless_notification.id)).to be false
      expect(Notification.exists?(recent_notification.id)).to be true
    end

    it "sends notification when notifications are deleted" do
      allow(MattermostClient).to receive(:send_to_notif_channel)
      service.call

      expect(MattermostClient).to have_received(:send_to_notif_channel).with(
        match(/Les notifications suivantes ont été supprimées automatiquement/)
      )
    end
  end
end
