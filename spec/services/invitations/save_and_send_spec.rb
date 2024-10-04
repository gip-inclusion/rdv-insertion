describe Invitations::SaveAndSend, type: :service do
  subject do
    described_class.call(invitation:, check_creneaux_availability:)
  end

  let!(:user) { create(:user) }
  let!(:invitation) { build(:invitation, user: user) }
  let(:check_creneaux_availability) { true }

  describe "#call" do
    before do
      allow(Invitations::AssignLinkAndToken).to receive(:call)
        .with(invitation:)
        .and_return(OpenStruct.new(success?: true))
      allow(Invitations::Validate).to receive(:call)
        .with(invitation:)
        .and_return(OpenStruct.new(success?: true))
      allow(RdvSolidaritesApi::RetrieveCreneauAvailability).to receive(:call)
        .with(link_params: invitation.link_params)
        .and_return(OpenStruct.new(success?: true, creneau_availability: true))
      allow(invitation).to receive_messages(send_to_user: OpenStruct.new(success?: true),
                                            rdv_solidarites_token?: false, link?: false)
    end

    it "is a success" do
      is_a_success
    end

    it "returns an invitation" do
      expect(subject.invitation).to eq(invitation)
    end

    it "assigns link and token to the invitation" do
      expect(Invitations::AssignLinkAndToken).to receive(:call)
        .with(invitation:)
      subject
    end

    it "saves an invitation" do
      expect { subject }.to change(Invitation, :count).by(1)
      expect(Invitation.last).to have_attributes(
        user: user,
        format: "sms",
        trigger: "manual"
      )
    end

    it "sends the invitation" do
      expect(invitation).to receive(:send_to_user)
      subject
    end

    context "when it fails to assign attributes" do
      before do
        allow(Invitations::AssignLinkAndToken).to receive(:call)
          .with(invitation:)
          .and_return(OpenStruct.new(success?: false, errors: ["cannot assign token"]))
      end

      it "is a failure" do
        is_a_failure
      end

      it "stores the error" do
        expect(subject.errors).to eq(["cannot assign token"])
      end
    end

    context "when the validation fails" do
      before do
        allow(Invitations::Validate).to receive(:call)
          .with(invitation:)
          .and_return(OpenStruct.new(success?: false, errors: ["validation failed"]))
      end

      it "is a failure" do
        is_a_failure
      end

      it "stores the error" do
        expect(subject.errors).to eq(["validation failed"])
      end
    end

    context "when it fails to send invitation" do
      before do
        allow(invitation).to receive(:send_to_user)
          .and_return(OpenStruct.new(success?: false, errors: ["something happened"]))
      end

      it "is a failure" do
        is_a_failure
      end

      it "stores the error" do
        expect(subject.errors).to eq(["something happened"])
      end

      it "does not create an invitation" do
        expect { subject }.not_to change(Invitation, :count)
      end
    end

    context "when there is a token and a link assigned already" do
      before do
        allow(invitation).to receive_messages(rdv_solidarites_token?: true, link?: true)
      end

      it("is a success") { is_a_success }

      it "does not call the assign link and token service" do
        expect(Invitations::AssignLinkAndToken).not_to receive(:call)
        subject
      end
    end

    context "when there are no creneau available on rdvs" do
      before do
        allow(RdvSolidaritesApi::RetrieveCreneauAvailability).to receive(:call)
          .with(link_params: invitation.link_params)
          .and_return(OpenStruct.new(success?: true, creneau_availability: false))
      end

      it("is a failure") { is_a_failure }

      it "stores an error message" do
        expect(subject.errors).to include(
          an_object_having_attributes(template_name: "no_creneau_available")
        )
        expect(subject.errors.first).to be_a(TemplatedErrorPresenter)
      end

      context "when we don't check the creneau availability" do
        let!(:check_creneaux_availability) { false }

        it("is a success") { is_a_success }

        it "does not call the retrieve creneau service" do
          expect(RdvSolidaritesApi::RetrieveCreneauAvailability).not_to receive(:call)
          subject
        end
      end
    end
  end
end
