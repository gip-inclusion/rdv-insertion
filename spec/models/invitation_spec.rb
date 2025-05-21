describe Invitation do
  describe "#valid?" do
    let!(:department) { create(:department) }
    let!(:organisation) { create(:organisation, department: department) }
    let!(:user) { create(:user) }
    let!(:follow_up) { build(:follow_up) }
    let!(:invitation) do
      build(
        :invitation,
        organisations: [organisation], department: department, follow_up: follow_up, format: "email",
        help_phone_number: "0101010101", user: user, rdv_solidarites_token: "rdv_solidarites_token",
        link: "https://www.rdv-solidarites.fr"
      )
    end

    it { expect(invitation).to be_valid }

    context "when no rdv_solidarites_token" do
      before { invitation.rdv_solidarites_token = nil }

      it { expect(invitation).not_to be_valid }
    end

    context "when no link" do
      before { invitation.link = nil }

      it { expect(invitation).not_to be_valid }
    end

    context "when no help_phone_number" do
      before { invitation.help_phone_number = nil }

      it { expect(invitation).not_to be_valid }
    end

    context "when no organisations" do
      before { invitation.organisations = [] }

      it { expect(invitation).not_to be_valid }
    end

    context "when no sms provider" do
      context "when format is sms" do
        before do
          invitation.format = "sms"
          invitation.save!
          invitation.sms_provider = nil
        end

        it { expect(invitation).not_to be_valid }
      end

      context "when format is email" do
        before { invitation.format = "email" }

        it { expect(invitation).to be_valid }
      end
    end
  end

  describe "#set_sms_provider" do
    subject { invitation.save! }

    let!(:invitation) { build(:invitation, format: "sms") }

    context "when primotexto is available and forced" do
      before do
        ENV["FORCE_PRIMOTEXTO"] = "true"
        ENV["PRIMOTEXTO_API_KEY"] = "api_key"
      end

      it "sets the sms provider to primotexto" do
        subject
        expect(invitation.reload.sms_provider).to eq("primotexto")
      end
    end

    context "when primotexto is not available" do
      before do
        ENV["FORCE_PRIMOTEXTO"] = "true"
        ENV["PRIMOTEXTO_API_KEY"] = nil
      end

      it "sets the sms provider to brevo" do
        subject
        expect(invitation.reload.sms_provider).to eq("brevo")
      end
    end

    context "when primotexto is not forced" do
      before do
        ENV["FORCE_PRIMOTEXTO"] = nil
        ENV["PRIMOTEXTO_API_KEY"] = nil
      end

      it "sets the sms provider to brevo" do
        subject
        expect(invitation.reload.sms_provider).to eq("brevo")
      end
    end

    context "when format is email" do
      before { invitation.format = "email" }

      it "does not set the sms provider" do
        subject
        expect(invitation.reload.sms_provider).to be_nil
      end
    end
  end
end
