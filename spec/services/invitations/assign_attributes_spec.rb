describe Invitations::AssignAttributes, type: :service do
  subject do
    described_class.call(invitation: invitation, rdv_solidarites_session: rdv_solidarites_session)
  end

  let!(:organisation) { create(:organisation) }
  let!(:rdv_solidarites_user_id) { 12 }
  let!(:applicant) do
    create(:applicant, invitations: [], rdv_solidarites_user_id: rdv_solidarites_user_id)
  end

  let!(:validity_duration) { 10.days }

  let!(:rdv_solidarites_session) { instance_double(RdvSolidaritesSession) }
  let!(:invitation) do
    build(:invitation, validity_duration: validity_duration, applicant: applicant, token: nil, link: nil)
  end
  let!(:token) { "some-token" }

  describe "#call" do
    let!(:invitation_link) { "https://www.rdv_solidarites.com/some_params" }

    before do
      travel_to(Time.zone.parse("2022-04-05 13:45"))
      allow(RdvSolidaritesApi::InviteUser).to receive(:call)
        .with(
          rdv_solidarites_user_id: rdv_solidarites_user_id, rdv_solidarites_session: rdv_solidarites_session,
          invite_for: validity_duration.to_i
        )
        .and_return(OpenStruct.new(success?: true, invitation_token: token))
      allow(Invitations::ComputeLink).to receive(:call)
        .with(invitation: invitation)
        .and_return(OpenStruct.new(success?: true, invitation_link: invitation_link))
    end

    it "is a success" do
      is_a_success
    end

    it "retrieves an invitation token" do
      expect(RdvSolidaritesApi::InviteUser).to receive(:call)
        .with(
          rdv_solidarites_user_id: rdv_solidarites_user_id, rdv_solidarites_session: rdv_solidarites_session,
          invite_for: validity_duration.to_i
        )
      subject
    end

    it "computes a link" do
      expect(Invitations::ComputeLink).to receive(:call).with(invitation: invitation)
      subject
    end

    it "sets the validity limit from the validity_duration" do
      subject
      expect(invitation.valid_until).to eq(Time.zone.parse("2022-04-15 13:45"))
    end

    it "assigns the invitationn with token and the link" do
      subject
      expect(invitation.link).to eq(invitation_link)
      expect(invitation.token).to eq(token)
    end

    context "when it fails to retrieve a token" do
      before do
        allow(RdvSolidaritesApi::InviteUser).to receive(:call)
          .and_return(OpenStruct.new(success?: false, errors: ["something happened with token"]))
      end

      it "is a failure" do
        is_a_failure
      end

      it "stores the error" do
        expect(subject.errors).to eq(["something happened with token"])
      end

      it "does not attach the token" do
        subject
        expect(invitation.token).to be_nil
      end

      it "does not save the invitation" do
        subject
        expect(invitation.id).to be_nil
      end
    end

    context "when it fails to compute the link" do
      before do
        allow(Invitations::ComputeLink).to receive(:call)
          .and_return(OpenStruct.new(success?: false, errors: ["something happened with link"]))
      end

      it "is a failure" do
        is_a_failure
      end

      it "stores the error" do
        expect(subject.errors).to eq(["something happened with link"])
      end

      it "does not attach the link" do
        subject
        expect(invitation.link).to be_nil
      end

      it "does not save the invitation" do
        subject
        expect(invitation.id).to be_nil
      end
    end

    context "when the applicant has already been invited" do
      let!(:other_invitation) do
        create(
          :invitation,
          sent_at: Time.zone.parse("2022-04-02 13:45"), token: "existing-token",
          valid_until: Time.zone.parse("2022-04-12 15:00")
        )
      end
      let!(:applicant) do
        create(:applicant, invitations: [other_invitation], rdv_solidarites_user_id: rdv_solidarites_user_id)
      end
      let!(:rdv_solidarites_user) { instance_double(RdvSolidarites::User) }

      before do
        allow(RdvSolidaritesApi::RetrieveInvitation).to receive(:call).with(
          token: "existing-token", rdv_solidarites_session: rdv_solidarites_session
        ).and_return(OpenStruct.new(user: rdv_solidarites_user))
      end

      it "checks if the token is valid by retrieving the associated user" do
        expect(RdvSolidaritesApi::RetrieveInvitation).to receive(:call).with(
          token: "existing-token", rdv_solidarites_session: rdv_solidarites_session
        )
        subject
      end

      it "is a success" do
        is_a_success
      end

      it "does not retrieve a new token" do
        expect(RdvSolidaritesApi::InviteUser).not_to receive(:call)
        subject
      end

      it "sets the validity limit from the previous invitation" do
        subject
        expect(invitation.valid_until).to eq(Time.zone.parse("2022-04-12 15:00"))
      end

      it "assign the existing token to the invitation" do
        subject
        expect(invitation.token).to eq("existing-token")
      end

      context "when the token is not associated to the user" do
        before do
          allow(RdvSolidaritesApi::RetrieveInvitation).to receive(:call)
            .with(token: "existing-token", rdv_solidarites_session: rdv_solidarites_session)
            .and_return(OpenStruct.new)
        end

        it "retrieves a new token" do
          expect(RdvSolidaritesApi::InviteUser).to receive(:call)
          subject
        end

        it "assign the new token to the invitation" do
          subject
          expect(invitation.token).to eq(token)
        end

        it "sets the validity limit from the validity_duration" do
          subject
          expect(invitation.valid_until).to eq(Time.zone.parse("2022-04-15 13:45"))
        end
      end

      context "when the previous invitation does not have a validity limit" do
        let!(:other_invitation) do
          create(
            :invitation,
            sent_at: Time.zone.parse("2022-04-02 13:45"), token: "existing-token"
          )
        end

        it "retrieves a new token" do
          expect(RdvSolidaritesApi::InviteUser).to receive(:call)
          subject
        end

        it "assign the new token to the invitation" do
          subject
          expect(invitation.token).to eq(token)
        end

        it "sets the validity limit from the validity_duration" do
          subject
          expect(invitation.valid_until).to eq(Time.zone.parse("2022-04-15 13:45"))
        end
      end
    end
  end
end
