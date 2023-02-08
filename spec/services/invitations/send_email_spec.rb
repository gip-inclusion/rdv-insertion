describe Invitations::SendEmail, type: :service do
  subject do
    described_class.call(
      invitation: invitation
    )
  end

  include_context "with all existing categories"

  let!(:applicant) { create(:applicant) }

  describe "#call" do
    before do
      allow(Messengers::SendEmail).to receive(:call)
        .and_return(OpenStruct.new(success?: true))
    end

    context "for rsa orientation" do
      let!(:invitation) do
        create(
          :invitation,
          applicant: applicant,
          rdv_context: build(:rdv_context, motif_category: category_rsa_orientation)
        )
      end

      it("is a success") { is_a_success }

      it "calls the emailer service" do
        expect(Messengers::SendEmail).to receive(:call)
          .with(
            sendable: invitation,
            mailer_class: InvitationMailer,
            mailer_method: :standard_invitation,
            invitation: invitation,
            applicant: applicant
          )
        subject
      end

      context "when the invitation is a reminder" do
        let!(:invitation) do
          create(
            :invitation,
            applicant: applicant,
            rdv_context: build(:rdv_context, motif_category: category_rsa_orientation),
            reminder: true
          )
        end

        it("is a success") { is_a_success }

        it "calls the emailer service with the reminder mailer method" do
          expect(Messengers::SendEmail).to receive(:call)
            .with(
              sendable: invitation,
              mailer_class: InvitationMailer,
              mailer_method: :standard_invitation_reminder,
              invitation: invitation,
              applicant: applicant
            )
          subject
        end
      end
    end

    context "for rsa_orientation_on_phone_platform" do
      let!(:invitation) do
        create(
          :invitation,
          applicant: applicant,
          rdv_context: build(:rdv_context, motif_category: category_rsa_orientation_on_phone_platform)
        )
      end

      it("is a success") { is_a_success }

      it "calls the emailer service" do
        expect(Messengers::SendEmail).to receive(:call)
          .with(
            sendable: invitation,
            mailer_class: InvitationMailer,
            mailer_method: :phone_platform_invitation,
            invitation: invitation,
            applicant: applicant
          )
        subject
      end

      context "when the invitation is a reminder" do
        let!(:invitation) do
          create(
            :invitation,
            applicant: applicant,
            rdv_context: build(:rdv_context, motif_category: category_rsa_orientation_on_phone_platform),
            reminder: true
          )
        end

        it("is a success") { is_a_success }

        it "calls the emailer service with the reminder mailer method" do
          expect(Messengers::SendEmail).to receive(:call)
            .with(
              sendable: invitation,
              mailer_class: InvitationMailer,
              mailer_method: :phone_platform_invitation_reminder,
              invitation: invitation,
              applicant: applicant
            )
          subject
        end
      end
    end

    context "for rsa_insertion_offer" do
      let!(:invitation) do
        create(
          :invitation,
          applicant: applicant,
          rdv_context: build(:rdv_context, motif_category: category_rsa_insertion_offer)
        )
      end

      it("is a success") { is_a_success }

      it "calls the emailer service" do
        expect(Messengers::SendEmail).to receive(:call)
          .with(
            sendable: invitation,
            mailer_class: InvitationMailer,
            mailer_method: :atelier_invitation,
            invitation: invitation,
            applicant: applicant
          )
        subject
      end
    end

    context "for rsa_atelier_competences" do
      let!(:invitation) do
        create(
          :invitation,
          applicant: applicant,
          rdv_context: build(:rdv_context, motif_category: category_rsa_atelier_competences)
        )
      end

      it("is a success") { is_a_success }

      it "calls the emailer service" do
        expect(Messengers::SendEmail).to receive(:call)
          .with(
            sendable: invitation,
            mailer_class: InvitationMailer,
            mailer_method: :atelier_invitation,
            invitation: invitation,
            applicant: applicant
          )
        subject
      end
    end

    context "for rsa_atelier_rencontres_pro" do
      let!(:invitation) do
        create(
          :invitation,
          applicant: applicant,
          rdv_context: build(:rdv_context, motif_category: category_rsa_atelier_rencontres_pro)
        )
      end

      it("is a success") { is_a_success }

      it "calls the emailer service" do
        expect(Messengers::SendEmail).to receive(:call)
          .with(
            sendable: invitation,
            mailer_class: InvitationMailer,
            mailer_method: :atelier_invitation,
            invitation: invitation,
            applicant: applicant
          )
        subject
      end
    end
  end
end
