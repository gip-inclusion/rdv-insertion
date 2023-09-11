describe InboundEmailsController do
  describe "#brevo" do
    before do
      allow(TransferEmailReplyJob).to receive(:perform_async)
      ENV["BREVO_INBOUND_PASSWORD"] = "T4ds4U"
    end

    context "when using a valid password" do
      let!(:brevo_params) { { items: [{ Subject: "Dummy email" }], password: "T4ds4U" } }

      it "enqueues the job that handles transferring the email" do
        expect(TransferEmailReplyJob).to receive(:perform_async)
          .with({ Subject: "Dummy email" })
        post :brevo, params: brevo_params, as: :json
        expect(response).to be_successful
      end
    end

    context "when using an invalid password" do
      let!(:brevo_params) { { items: [{ Subject: "Dummy email" }], password: "inv4l1d" } }

      it "does not enqueue any job" do
        expect(TransferEmailReplyJob).not_to receive(:perform_async)
        post :brevo, params: brevo_params, as: :json
        expect(response).not_to be_successful
      end

      it "warns Sentry" do
        expect(Sentry).to receive(:capture_message).with("Brevo inbound controller was called without valid password")
        post :brevo, params: brevo_params, as: :json
      end
    end
  end
end
