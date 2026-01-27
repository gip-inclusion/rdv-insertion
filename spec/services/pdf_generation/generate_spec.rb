describe PdfGeneration::Generate, type: :service do
  subject { described_class.call(content: content) }

  let(:content) { "<html><body>Test content</body></html>" }

  describe "#call" do
    context "when PDF generation succeeds" do
      before { mock_pdf_service }

      it("is a success") { is_a_success }

      it "returns pdf_data" do
        expect(subject.pdf_data).to be_present
      end
    end

    context "when PDF generation fails" do
      before { allow(Sentry).to receive(:capture_message) }

      context "when the PDF service returns an error" do
        before do
          allow(PdfGeneratorClient).to receive(:generate_pdf).and_return(
            instance_double(Faraday::Response, success?: false, status: 500, body: "Internal Server Error")
          )
        end

        it("is a failure") { is_a_failure }

        it "sets error_type to :server_error" do
          expect(subject.error_type).to eq(:server_error)
        end

        it "notifies Sentry" do
          subject
          expect(Sentry).to have_received(:capture_message).with(
            "PDF generation failed",
            extra: { status: 500, body: "Internal Server Error" }
          )
        end
      end

      context "when the PDF service times out" do
        before do
          allow(PdfGeneratorClient).to receive(:generate_pdf).and_raise(Faraday::TimeoutError)
        end

        it("is a failure") { is_a_failure }

        it "sets error_type to :timeout" do
          expect(subject.error_type).to eq(:timeout)
        end

        it "notifies Sentry" do
          subject
          expect(Sentry).to have_received(:capture_message).with(
            "PDF generation failed",
            extra: hash_including(exception: "Faraday::TimeoutError")
          )
        end
      end

      context "when the PDF service is unreachable" do
        before do
          allow(PdfGeneratorClient).to receive(:generate_pdf).and_raise(
            Faraday::ConnectionFailed.new("Connection refused")
          )
        end

        it("is a failure") { is_a_failure }

        it "sets error_type to :connection_failed" do
          expect(subject.error_type).to eq(:connection_failed)
        end

        it "notifies Sentry" do
          subject
          expect(Sentry).to have_received(:capture_message).with(
            "PDF generation failed",
            extra: hash_including(exception: "Faraday::ConnectionFailed")
          )
        end
      end
    end
  end
end
