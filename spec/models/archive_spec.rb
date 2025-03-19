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
    let!(:other_organisation) { create(:organisation, department:) }
    let!(:other_archived_organisation) { create(:organisation, department:) }
    let!(:archive) { create(:archive, user:, organisation: other_archived_organisation) }
    let!(:invitation_for_organisation) do
      create(:invitation, user:, department:, organisations: [organisation])
    end

    let!(:invitation_for_other_organisation) do
      create(:invitation, user:, department:, organisations: [other_organisation])
    end

    let!(:invitation_for_two_organisations) do
      create(:invitation, user:, department:, organisations: [organisation, other_organisation])
    end

    let!(:invitation_for_two_archived_organisations) do
      create(:invitation, user:, department:, organisations: [organisation, other_archived_organisation])
    end

    it "invalidates the user organisation invitations" do
      expect(ExpireInvitationJob).to receive(:perform_later)
        .with(invitation_for_organisation.id)
      expect(ExpireInvitationJob).not_to receive(:perform_later)
        .with(invitation_for_other_organisation.id)
      expect(ExpireInvitationJob).not_to receive(:perform_later)
        .with(invitation_for_two_organisations.id)
      expect(ExpireInvitationJob).to receive(:perform_later)
        .with(invitation_for_two_archived_organisations.id)

      subject.save
    end
  end
end
