describe Messengers::SendEmail, type: :service do
  subject do
    described_class.call(
      sendable: notification,
      mailer_class: mailer_class,
      mailer_method: mailer_method,
      some_attribute: some_attribute,
      another_attribute: another_attribute
    )
  end

  describe "#call" do
    let!(:notification) { create(:notification, format: "email", applicant: applicant) }
    let!(:applicant) { create(:applicant, email: email) }
    let!(:email) { "someone@beta.gouv.fr" }

    let!(:mailer_class) { instance_double("mailer") }
    let!(:mailer_method) { :some_mailer_method }
    let!(:some_attribute) { "some attribute" }
    let!(:another_attribute) { "another attribute" }

    let!(:mailer_with) { instance_double("mailer_with") }
    let!(:mailer_with_method) { instance_double("mailer_with_method") }

    before do
      allow(mailer_class).to receive(:with).and_return(mailer_with)
      allow(mailer_with).to receive(mailer_method).and_return(mailer_with_method)
      allow(mailer_with_method).to receive(:deliver_now)
    end

    it("is a success") { is_a_success }

    it "calls the right method on the right mailer with the right arguments" do
      expect(mailer_class).to receive(:with)
        .with(
          { some_attribute: some_attribute, another_attribute: another_attribute }
        )
      expect(mailer_with).to receive(mailer_method)
      expect(mailer_with_method).to receive(:deliver_now)
      subject
    end

    context "when the sendable format is not email" do
      before { notification.format = "sms" }

      it("is a failure") { is_a_failure }

      it "returns an error" do
        expect(subject.errors).to eq(["Envoi d'un email alors que le format est sms"])
      end
    end

    context "when the email is blank" do
      let!(:email) { nil }

      it("is a failure") { is_a_failure }

      it "returns the error" do
        expect(subject.errors).to eq(["L'email doit être renseigné"])
      end
    end

    context "when the email format is not valid" do
      before { applicant.email = "someinvalidmail" }

      it("is a failure") { is_a_failure }

      it "returns the error" do
        expect(subject.errors).to eq(["L'email renseigné ne semble pas être une adresse valable"])
      end
    end
  end
end
