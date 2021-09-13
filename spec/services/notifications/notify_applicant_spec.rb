class TestService < Notifications::NotifyApplicant
  def content
    "test"
  end
end

describe Notifications::NotifyApplicant, type: :service do
  subject do
    TestService.call(
      applicant: applicant, lieu: lieu, starts_at: starts_at, motif: motif
    )
  end

  let!(:phone_number) { "+33782605941" }
  let!(:applicant) { create(:applicant, phone_number_formatted: phone_number) }
  let!(:notification) { create(:notification, applicant: applicant) }
  let!(:lieu) { { name: "DINUM", address: "20 avenue de Ségur" } }
  let!(:motif) { { location_type: "public_office" } }
  let!(:starts_at) { "2021-09-08 12:00:00 UTC" }

  describe "#call" do
    before do
      allow(Notification).to receive(:new).and_return(notification)
      allow(notification).to receive(:save).and_return(true)
      allow(SendTransactionalSms).to receive(:call).and_return(OpenStruct.new(success?: true))
      allow(notification).to receive(:update).and_return(true)
    end

    context "when the phone number is missing" do
      let!(:applicant) { create(:applicant, phone_number_formatted: "") }

      it("is a failure") { is_a_failure }

      it "stores the errors message" do
        expect(subject.errors).to eq(["le téléphone n'est pas renseigné"])
      end
    end

    it "creates a notification" do
      expect(Notification).to receive(:new)
        .with(event: "test_service", applicant: applicant)
      expect(notification).to receive(:save)
      subject
    end

    it "sends the sms" do
      expect(SendTransactionalSms).to receive(:call)
        .with(phone_number: phone_number, content: "test")
      subject
    end

    it "updates the notification" do
      expect(notification).to receive(:update)
      subject
    end

    context "when the notification cannot be saved" do
      before do
        allow(notification).to receive(:save).and_return(false)
        allow(notification).to receive_message_chain(:errors, :full_messages, :to_sentence)
          .and_return("some error")
      end

      it "does not send the sms" do
        expect(SendTransactionalSms).not_to receive(:call)
      end

      it "rollback the transaction" do
        expect(Notification).to receive(:transaction) do |&block|
          expect { block.call }.to raise_error(ActiveRecord::Rollback)
        end.and_return(nil)
        subject
      end

      it("is a failure") { is_a_failure }

      it "stores the error message" do
        expect(subject.errors).to eq(["some error"])
      end
    end

    context "when the sms service fails" do
      before do
        allow(SendTransactionalSms).to receive(:call)
          .and_return(OpenStruct.new(success?: false, errors: ["bad request"]))
      end

      it("is a failure") { is_a_failure }

      it "stores the error message" do
        expect(subject.errors).to eq(["bad request"])
      end

      it "rollback the transaction" do
        expect(Notification).to receive(:transaction) do |&block|
          expect { block.call }.to raise_error(ActiveRecord::Rollback)
        end.and_return(nil)
        subject
      end

      it "does not update the notification" do
        expect(notification).not_to receive(:update)
        subject
      end
    end

    context "when the notification cannot be updated" do
      before do
        allow(notification).to receive(:update)
          .and_return(false)
        allow(notification).to receive_message_chain(:errors, :full_messages, :to_sentence)
          .and_return("some error")
      end

      it("is a failure") { is_a_failure }

      it "stores the error message" do
        expect(subject.errors).to eq(["some error"])
      end
    end
  end
end
