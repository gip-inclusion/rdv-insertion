describe Participation do
  describe "rdv_solidarites_participation_id uniqueness validation" do
    context "no collision" do
      let(:participation) { build(:participation, rdv_solidarites_participation_id: 1) }

      it { expect(participation).to be_valid }
    end

    context "blank rdv_solidarites_participation_id" do
      let!(:participation_existing) { create(:participation, rdv_solidarites_participation_id: 1) }

      let(:participation) { build(:participation, rdv_solidarites_participation_id: "") }

      it { expect(participation).to be_valid }
    end

    context "colliding rdv_solidarites_participation_id" do
      let!(:participation_existing) { create(:participation, rdv_solidarites_participation_id: 1) }
      let(:participation) { build(:participation, rdv_solidarites_participation_id: 1) }

      it "adds errors" do
        expect(participation).not_to be_valid
        expect(participation.errors.details).to eq({ rdv_solidarites_participation_id: [{ error: :taken, value: 1 }] })
        expect(participation.errors.full_messages.to_sentence)
          .to include("Rdv solidarites participation est déjà utilisé")
      end
    end
  end

  describe "#possible_new_statuses" do
    subject { participation.possible_new_statuses }

    let(:participation) { build(:participation, rdv: rdv, status: "unknown") }

    context "when rdv is in the past" do
      let(:rdv) { create(:rdv, starts_at: DateTime.yesterday) }

      it { expect(subject.sort).to eq(%w[excused seen noshow revoked].sort) }

      context "when the particiption is excused" do
        before { participation.status = "excused" }

        it { expect(subject.sort).to eq(%w[seen noshow revoked].sort) }
      end

      context "when the particiption is revoked" do
        before { participation.status = "revoked" }

        it { expect(subject.sort).to eq(%w[excused seen noshow].sort) }
      end
    end

    context "when rdv is in the future" do
      let(:rdv) { create(:rdv, starts_at: DateTime.tomorrow) }

      it { expect(subject.sort).to eq(%w[excused revoked].sort) }

      context "when the particiption is excused" do
        before { participation.status = "excused" }

        it { expect(subject.sort).to eq(%w[unknown revoked].sort) }
      end

      context "when the particiption is revoked" do
        before { participation.status = "revoked" }

        it { expect(subject.sort).to eq(%w[unknown excused].sort) }
      end
    end
  end

  describe "#notify_users" do
    subject { participation.save }

    let!(:participation_id) { 333 }
    let!(:rdv) { create(:rdv, starts_at: 2.days.from_now) }
    let!(:user) { create(:user) }
    let!(:participation) do
      build(:participation, id: participation_id, convocable: true, rdv: rdv, user: user, status: "unknown")
    end

    context "after record creation" do
      it "enqueues a job to notify the user" do
        expect(NotifyParticipationToUserJob).to receive(:perform_later)
          .with(participation.id, "sms", "participation_created")
        expect(NotifyParticipationToUserJob).to receive(:perform_later)
          .with(participation.id, "email", "participation_created")
        subject
      end

      context "when the rdv is not convocable" do
        before { participation.update! convocable: false }

        it "does not enqueue a notify users job" do
          expect(NotifyParticipationToUserJob).not_to receive(:perform_later)
          subject
        end
      end

      context "when the user has no email" do
        let!(:user) { create(:user, email: nil) }

        it "enqueues a job to notify by sms only" do
          expect(NotifyParticipationToUserJob).to receive(:perform_later)
            .with(participation_id, "sms", "participation_created")
          expect(NotifyParticipationToUserJob).not_to receive(:perform_later)
            .with(participation_id, "email", "participation_created")
          subject
        end
      end

      context "when the user has no phone" do
        let!(:user) { create(:user, phone_number: nil) }

        it "enqueues a job to notify by sms only" do
          expect(NotifyParticipationToUserJob).not_to receive(:perform_later)
            .with(participation_id, "sms", "participation_created")
          expect(NotifyParticipationToUserJob).to receive(:perform_later)
            .with(participation_id, "email", "participation_created")
          subject
        end
      end
    end

    context "when the rdv is in the past" do
      before { rdv.update! starts_at: 2.days.ago }

      it "doess not enqueue jobs" do
        expect(NotifyParticipationToUserJob).not_to receive(:perform_later)
        subject
      end
    end

    context "after revocation" do
      let!(:participation) do
        create(
          :participation,
          rdv: rdv,
          user: user,
          convocable: true,
          status: "unknown"
        )
      end

      it "enqueues a job to notify rdv users" do
        participation.status = "revoked"
        expect(NotifyParticipationToUserJob).to receive(:perform_later)
          .with(participation.id, "sms", "participation_cancelled")
        expect(NotifyParticipationToUserJob).to receive(:perform_later)
          .with(participation.id, "email", "participation_cancelled")
        subject
      end

      context "when the rdv is not convocable" do
        before { participation.update! convocable: false }

        it "does not enqueue a notify users job" do
          expect(NotifyParticipationToUserJob).not_to receive(:perform_later)
          subject
        end
      end

      context "when the participation is already cancelled" do
        let!(:participation) do
          create(
            :participation,
            rdv: rdv,
            user: user,
            convocable: true,
            status: "revoked"
          )
        end

        it "does not enqueue a notify users job" do
          participation.status = "revoked"
          expect(NotifyParticipationToUserJob).not_to receive(:perform_later)
          subject
        end
      end

      context "when the rdv is excused" do
        it "does not notify the user" do
          participation.status = "excused"
          expect(NotifyParticipationToUserJob).not_to receive(:perform_later)
          subject
        end
      end
    end
  end

  describe "#destroy" do
    subject { participation1.destroy }

    let!(:participation1) { create(:participation, user: user1, follow_up: follow_up1) }
    let!(:user1) { create(:user, follow_ups: [follow_up1, follow_up2]) }
    let!(:follow_up1) { create(:follow_up, motif_category: create(:motif_category), status: "rdv_seen") }
    let!(:follow_up2) { create(:follow_up, motif_category: create(:motif_category), status: "rdv_seen") }

    it "schedules a refresh_user_context_statuses job" do
      expect(RefreshFollowUpStatusesJob).to receive(:perform_later).with(follow_up1.id)
      subject
    end
  end

  describe "#notifiable?" do
    subject { participation.notifiable? }

    let!(:rdv) { create(:rdv, starts_at: 2.days.from_now) }
    let!(:participation) { create(:participation, convocable: true, rdv:, status: "unknown") }

    it "is notifiable if it is convocable and in the future" do
      expect(subject).to eq(true)
    end

    context "when the rdv is in the past" do
      let!(:rdv) { create(:rdv, starts_at: 2.days.ago) }

      it "is not notifiable" do
        expect(subject).to eq(false)
      end
    end

    context "when it is not convocable" do
      before { participation.update! convocable: false }

      it "is not notifiable" do
        expect(subject).to eq(false)
      end
    end

    context "when the status is excused" do
      before { participation.update! status: "excused" }

      it "is not notifiable" do
        expect(subject).to eq(false)
      end
    end
  end

  describe "#eligible_for_france_travail_webhook?" do
    subject { participation.eligible_for_france_travail_webhook? }

    let!(:participation) { create(:participation, user:, rdv: create(:rdv, organisation:)) }
    let!(:organisation) { create(:organisation, organisation_type: "conseil_departemental") }
    let!(:user) { create(:user, :with_valid_nir) }

    context "when the user is not marked for rgpd destruction" do
      it "is eligible" do
        expect(subject).to eq(true)
      end
    end

    context "when the user is marked for rgpd destruction" do
      before { user.mark_for_rgpd_destruction }

      it "is not eligible" do
        expect(subject).to eq(false)
      end
    end

    context "when the organisation is not a conseil departemental or delegataire" do
      let!(:organisation) { create(:organisation, organisation_type: "siae") }

      it "is not eligible" do
        expect(subject).to eq(false)
      end
    end

    context "when the user has no nir" do
      let!(:user) { create(:user) }

      it "is not eligible" do
        expect(subject).to eq(false)
      end
    end
  end

  describe "france travail webhook callbacks on update" do
    let!(:department) { create(:department) }
    let!(:organisation) { create(:organisation, organisation_type: "conseil_departemental", department: department) }
    let!(:user) { create(:user, :with_valid_nir) }
    let!(:rdv) { create(:rdv, organisation: organisation) }
    let!(:now) { Time.zone.parse("21/01/2023 23:42:11") }

    before do
      travel_to now
      allow(OutgoingWebhooks::FranceTravail::CreateParticipationJob).to receive(:perform_later)
      allow(OutgoingWebhooks::FranceTravail::UpdateParticipationJob).to receive(:perform_later)
    end

    context "when participation becomes newly eligible on update" do
      let!(:participation) do
        create(:participation, rdv: rdv, user: user, organisation: organisation, france_travail_id: nil)
      end

      it "triggers CreateParticipationJob instead of UpdateParticipationJob" do
        expect(OutgoingWebhooks::FranceTravail::CreateParticipationJob).to receive(:perform_later)
          .with(
            participation_id: participation.id,
            timestamp: now
          )
        expect(OutgoingWebhooks::FranceTravail::UpdateParticipationJob).not_to receive(:perform_later)

        participation.save
      end
    end

    context "when participation is already eligible and has france_travail_id" do
      let!(:participation) do
        create(:participation, rdv: rdv, user: user, organisation: organisation, france_travail_id: "ft-123")
      end

      it "triggers UpdateParticipationJob" do
        expect(OutgoingWebhooks::FranceTravail::UpdateParticipationJob).to receive(:perform_later)
          .with(
            participation_id: participation.id,
            timestamp: now
          )
        expect(OutgoingWebhooks::FranceTravail::CreateParticipationJob).not_to receive(:perform_later)

        participation.save
      end
    end
  end
end
