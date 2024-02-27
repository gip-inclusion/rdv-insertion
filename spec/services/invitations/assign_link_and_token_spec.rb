describe Invitations::AssignLinkAndToken, type: :service do
  subject do
    described_class.call(invitation:)
  end

  let!(:organisation) { create(:organisation) }
  let!(:rdv_solidarites_user_id) { 12 }
  let!(:user) do
    create(:user, invitations: [], rdv_solidarites_user_id: rdv_solidarites_user_id)
  end
  let!(:invitation) do
    build(:invitation, user: user, rdv_solidarites_token: nil, link: nil)
  end
  let!(:rdv_solidarites_token) { "uptodate-token" }

  describe "#call" do
    let!(:invitation_link) { "https://www.rdv_solidarites.com/some_params" }

    before do
      travel_to(Time.zone.parse("2022-04-05 13:45"))
      allow(RdvSolidaritesApi::CreateOrRetrieveInvitationToken).to receive(:call)
        .with(rdv_solidarites_user_id:)
        .and_return(OpenStruct.new(success?: true, invitation_token: rdv_solidarites_token))
      allow(Invitations::ComputeLink).to receive(:call)
        .with(invitation: invitation)
        .and_return(OpenStruct.new(success?: true, invitation_link: invitation_link))
    end

    it "is a success" do
      is_a_success
    end

    it "retrieves an invitation token" do
      expect(RdvSolidaritesApi::CreateOrRetrieveInvitationToken).to receive(:call)
        .with(rdv_solidarites_user_id:)
      subject
    end

    it "computes a link" do
      expect(Invitations::ComputeLink).to receive(:call)
        .with(invitation: invitation)
      subject
    end

    it "assigns the invitationn with token and the link" do
      subject
      expect(invitation.link).to eq(invitation_link)
      expect(invitation.rdv_solidarites_token).to eq(rdv_solidarites_token)
    end

    context "when it fails to retrieve a token" do
      before do
        allow(RdvSolidaritesApi::CreateOrRetrieveInvitationToken).to receive(:call)
          .and_return(OpenStruct.new(success?: false, errors: ["something happened with token"]))
      end

      it "is a failure" do
        is_a_failure
      end

      it "stores the error" do
        expect(subject.errors).to eq(["something happened with token"])
      end

      it "does not attach the rdv_solidarites_token" do
        subject
        expect(invitation.rdv_solidarites_token).to be_nil
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
  end
end
