describe Archive do
  subject { build(:archive, organisation: organisation, user: user) }

  let!(:department) { create(:department) }
  let!(:organisation) { create(:organisation, department:) }
  let!(:user) { create(:user) }

  describe "xss attempt" do
    let(:archiving_reason) { "\"><img src=1 onerror=alert(1)>" }
    let!(:archive) { create(:archive, archiving_reason:, organisation:, user:) }

    it "strips all html" do
      expect(archive.reload.archiving_reason).to eq("\">")
    end

    describe "attempt logging on sentry" do
      subject { create(:archive, archiving_reason:, organisation:, user: other_user) }

      let(:other_user) { create(:user) }

      context "message is legit" do
        let(:archiving_reason) do
          "Suivi accompagnement\n\r\t Envoyer des offres &  d'emploi et d'entreprises pour son alternance "
        end

        it "does not log" do
          expect(Sentry).not_to receive(:capture_message)
          subject
        end
      end

      context "message is not legit" do
        let(:archiving_reason) { "\"><img src=1 onerror=alert(1)>" }

        it "logs on sentry" do
          expect(Sentry).to receive(:capture_message).once
          subject
        end
      end
    end
  end

  describe "no collision" do
    context "when the user is not archived" do
      let(:archive) { build(:archive, organisation: organisation, user: user) }

      it { expect(subject).to be_valid }
    end

    context "when the user is archived in another organisation" do
      let!(:existing_archive) do
        create(:archive, user: user, organisation: create(:organisation))
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
    let!(:department) { create(:department) }
    let!(:organisation) { create(:organisation, department:) }
    let!(:archive) { build(:archive, user:, organisation:) }
    let!(:user) { create(:user, organisations: [organisation, other_organisation]) }
    let!(:other_organisation) { create(:organisation, department:) }
    let!(:invitation) do
      create(:invitation, user:, department:,
                          organisations: [organisation, other_organisation, organisation_user_does_not_belong_to])
    end
    let!(:organisation_user_does_not_belong_to) { create(:organisation, department:) }

    context "when the user is not archived in all the organisations he shares with the invitation" do
      it "does not invalidate the invitation" do
        expect(ExpireInvitationJob).not_to receive(:perform_later).with(invitation.id)
        archive.save!
      end
    end

    context "when the user is archived in all the organisations he shares with the invitation" do
      let!(:archive_in_other_organisation) do
        create(:archive, user:, organisation: other_organisation, archiving_reason: "test")
      end

      it "invalidates the invitation" do
        expect(ExpireInvitationJob).to receive(:perform_later).with(invitation.id)
        archive.save!
      end
    end
  end
end
