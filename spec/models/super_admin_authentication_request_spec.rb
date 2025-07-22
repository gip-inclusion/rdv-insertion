describe SuperAdminAuthenticationRequest, type: :model do
  describe "#verify" do
    subject { super_admin_authentication_request.verify(token) }

    let(:super_admin_authentication_request) { create(:super_admin_authentication_request) }
    let(:token) { "123456" }
    let(:now) { Time.zone.now }

    before { travel_to(now) }

    describe "#verify" do
      subject { super_admin_authentication_request.verify(token) }

      context "when the token is correct" do
        before { super_admin_authentication_request.update!(token: token) }

        it "verifies the request" do
          expect(subject).to be_truthy
        end

        it "sets the verified_at" do
          expect { subject }.to change(super_admin_authentication_request, :verified_at)
          expect(super_admin_authentication_request.verified_at).to be_present
        end

        it "increments the verification_attempts" do
          expect { subject }.to change(super_admin_authentication_request, :verification_attempts).by(1)
        end
      end

      context "when the token is incorrect" do
        it "does not verify the request" do
          expect(subject).to be_falsy
        end

        it "does not set the verified_at" do
          expect { subject }.not_to change(super_admin_authentication_request, :verified_at)
        end

        it "increments the verification_attempts" do
          expect { subject }.to change(super_admin_authentication_request, :verification_attempts).by(1)
        end

        it "adds an error" do
          subject
          expect(super_admin_authentication_request.errors).to be_present
          expect(super_admin_authentication_request.errors.full_messages).to include(
            "Le code d'authentification est invalide. Veuillez réessayer."
          )
        end
      end

      context "when the token is expired" do
        before { super_admin_authentication_request.update!(created_at: 11.minutes.ago) }

        it "does not verify the request" do
          expect(subject).to be_falsy
        end

        it "adds an error" do
          subject
          expect(super_admin_authentication_request.errors).to be_present
          expect(super_admin_authentication_request.errors.full_messages).to include(
            "Le code d'authentification a expiré. Veuillez en générer un nouveau."
          )
        end

        it "increments the verification_attempts" do
          expect { subject }.to change(super_admin_authentication_request, :verification_attempts).by(1)
        end
      end

      context "when the request has been invalidated" do
        before { super_admin_authentication_request.update!(invalidated_at: now) }

        it "does not verify the request" do
          expect(subject).to be_falsy
        end

        it "adds an error" do
          subject
          expect(super_admin_authentication_request.errors).to be_present
          expect(super_admin_authentication_request.errors.full_messages).to include(
            "La demande d'authentification n'est plus valide. Veuillez en générer une nouvelle."
          )
        end

        it "does not set the verified_at" do
          expect { subject }.not_to change(super_admin_authentication_request, :verified_at)
        end

        it "increments the verification_attempts" do
          expect { subject }.to change(super_admin_authentication_request, :verification_attempts).by(1)
        end
      end

      context "when it attempts too many times" do
        before { super_admin_authentication_request.update!(verification_attempts: 4) }

        it "does not verify the request" do
          expect(subject).to be_falsy
          expect(super_admin_authentication_request.invalidated_at).to be_present
        end
      end
    end
  end

  describe "#belongs_to_super_admin" do
    let(:agent) { create(:agent) }
    let(:super_admin_authentication_request) { build(:super_admin_authentication_request, agent: agent) }

    context "when the agent is not a super admin" do
      it "adds an error" do
        expect(super_admin_authentication_request).not_to be_valid
        expect(super_admin_authentication_request.errors).to be_present
        expect(super_admin_authentication_request.errors.full_messages).to include("Vous n'êtes pas un super admin.")
      end
    end

    context "when the agent is a super admin" do
      let(:agent) { create(:agent, :super_admin) }

      it "does not add an error" do
        expect(super_admin_authentication_request).to be_valid
        expect(super_admin_authentication_request.errors).to be_blank
      end
    end
  end

  describe "#verified_and_valid?" do
    subject { super_admin_authentication_request.verified_and_valid? }

    let(:super_admin_authentication_request) { create(:super_admin_authentication_request) }

    context "when the request is not verified" do
      before { super_admin_authentication_request.update!(verified_at: nil) }

      it { is_expected.to be_falsy }
    end

    context "when the request is verified" do
      before { super_admin_authentication_request.update!(verified_at: Time.current) }

      it { is_expected.to be_truthy }
    end

    context "when the request is invalidated" do
      before { super_admin_authentication_request.update!(invalidated_at: Time.current) }

      it { is_expected.to be_falsy }
    end

    context "when the request is no longer valid" do
      before { super_admin_authentication_request.update!(verified_at: 13.hours.ago) }

      it { is_expected.to be_falsy }
    end
  end
end
