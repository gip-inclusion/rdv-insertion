describe Organisations::RgpdCleanup, type: :service do
  subject { described_class.call(organisation: organisation, dry_run: dry_run) }

  let(:dry_run) { false }
  let(:organisation) { create(:organisation, data_retention_duration_in_months: 24) }

  describe "#call" do
    let(:old_date) { 25.months.ago }
    let(:recent_date) { 1.month.ago }

    let!(:inactive_user) { create(:user) }
    let!(:active_user) { create(:user) }
    let!(:inactive_user_organisation) do
      create(:users_organisation, user: inactive_user, organisation: organisation, created_at: old_date)
    end
    let!(:active_user_organisation) do
      create(:users_organisation, user: active_user, organisation: organisation, created_at: recent_date)
    end

    context "when user is only in current organisation" do
      it "destroys the user completely" do
        allow(MattermostClient).to receive(:send_to_rgpd_cleanup_channel)

        expect { subject }.to change(User, :count).by(-1)
        expect(User.exists?(inactive_user.id)).to be false
        expect(User.exists?(active_user.id)).to be true
      end

      it "sends deletion notification" do
        allow(MattermostClient).to receive(:send_to_rgpd_cleanup_channel)

        subject

        expect(MattermostClient).to have_received(:send_to_rgpd_cleanup_channel).with(
          match(/Les usagers suivants ont été supprimés pour inactivité dans l'organisation #{organisation.name}/)
        )
      end
    end

    context "when user is in multiple organisations" do
      let(:other_organisation) { create(:organisation, data_retention_duration_in_months: 24) }
      let!(:inactive_user_organisation_other_organisation) do
        create(:users_organisation, user: inactive_user, organisation: other_organisation, created_at: old_date)
      end

      it "removes user from current organisation only" do
        allow(MattermostClient).to receive(:send_to_rgpd_cleanup_channel)

        expect { subject }.not_to change(User, :count)
        expect(User.exists?(inactive_user.id)).to be true
        expect(inactive_user.reload.users_organisations.where(organisation: organisation)).to be_empty
        expect(inactive_user.users_organisations.where(organisation: other_organisation)).to be_present
      end

      it "sends removal notification" do
        allow(MattermostClient).to receive(:send_to_rgpd_cleanup_channel)

        subject

        expect(MattermostClient).to have_received(:send_to_rgpd_cleanup_channel).with(
          match(/Les usagers suivants ont été retirés de l'organisation #{organisation.name} pour inactivité/)
        )
      end
    end

    context "when rdvs are useless" do
      let(:old_date) { 25.months.ago }
      let(:recent_date) { 1.month.ago }
      let!(:webhook_endpoint) { create(:webhook_endpoint, organisation:, subscriptions: %w[rdv]) }

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

      it "destroys old rdvs without participations and does not send webhooks" do
        expect(OutgoingWebhooks::SendWebhookJob).not_to receive(:perform_later)
        expect { subject }.to change(Rdv, :count).by(-1)
        expect(Rdv.exists?(useless_rdv.id)).to be false
        expect(Rdv.exists?(recent_rdv.id)).to be true
      end

      it "sends notification when rdvs are deleted" do
        allow(MattermostClient).to receive(:send_to_rgpd_cleanup_channel)
        subject

        expect(MattermostClient).to have_received(:send_to_rgpd_cleanup_channel).with(
          match(/Les rdvs suivants ont été supprimés automatiquement pour l'organisation #{organisation.name}/)
        )
      end
    end

    context "when dry run is enabled" do
      let!(:dry_run) { true }

      before do
        allow(MattermostClient).to receive(:send_to_rgpd_cleanup_channel)
      end

      it "does not destroy users" do
        expect { subject }.not_to change(User, :count)
        expect(User.exists?(inactive_user.id)).to be true
        expect(User.exists?(active_user.id)).to be true
      end

      it "does not destroy rdvs" do
        expect { subject }.not_to change(Rdv, :count)
      end

      it "does not remove users from org" do
        expect { subject }.not_to change(UsersOrganisation, :count)
        expect(inactive_user.reload.users_organisations.where(organisation: organisation)).to be_present
        expect(active_user.reload.users_organisations.where(organisation: organisation)).to be_present
      end

      it "still sends notification when users are to be deleted" do
        subject

        expect(MattermostClient).to have_received(:send_to_rgpd_cleanup_channel).with(
          match(
            /\[🔍 DRY RUN\] 🚮 Les usagers suivants ont été supprimés pour inactivité dans l'organisation/
          )
        )
      end
    end
  end
end
