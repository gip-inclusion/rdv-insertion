describe Archive do
  subject { build(:archive, organisation: organisation, user: user) }

  let!(:department) { create(:department) }
  let!(:organisation) { create(:organisation, department:) }
  let!(:user) { create(:user, organisations: [organisation]) }

  describe "user must belong to organisation" do
    let!(:user) { create(:user, organisations: [create(:organisation)]) }

    it "is not valid" do
      expect(subject).not_to be_valid
      expect(subject.errors.full_messages).to include("Usager doit appartenir à l'organisation")
    end
  end

  describe "xss attempt" do
    let!(:archiving_reason) { "\"><img src=1 onerror=alert(1)>" }
    let!(:archive) { build(:archive, archiving_reason:, organisation:, user:) }

    it "strips all html" do
      archive.save!
      expect(archive.archiving_reason).to eq("\">")
    end

    describe "attempt logging on sentry" do
      context "message is legit" do
        let!(:archiving_reason) do
          "Suivi accompagnement\n\r\t Envoyer des offres &  d'emploi et d'entreprises pour son alternance "
        end

        it "does not log" do
          expect(Sentry).not_to receive(:capture_message)
          archive.save!
        end
      end

      context "message is not legit" do
        let!(:archiving_reason) { "\"><img src=1 onerror=alert(1)>" }

        it "logs on sentry" do
          expect(Sentry).to receive(:capture_message).once
          archive.save!
        end
      end
    end
  end

  describe "no collision" do
    context "when the user is not archived" do
      let!(:archive) { build(:archive, organisation: organisation, user: user) }

      it { expect(subject).to be_valid }
    end

    context "when the user is archived in another organisation" do
      let!(:existing_archive) do
        create(:archive, user: user, organisation: create(:organisation, users: [user]))
      end

      it { expect(subject).to be_valid }
    end

    context "when the user is already archived in the organisation" do
      let!(:existing_archive) do
        create(:archive, user: user, organisation: organisation)
      end

      it { expect(subject).not_to be_valid }
    end
  end

  describe "invitation invalidations" do
    let!(:archive) { build(:archive, user:, organisation:) }

    it "enqueues a job to invalidate related invitations on creation" do
      expect(InvalidateInvitationsAfterArchivingJob).to receive(:perform_later)
      archive.save!
    end
  end
end
