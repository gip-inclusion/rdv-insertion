describe BaseService, type: :service do
  subject { BaseService.call }
  let(:service) { double("service") }

  describe "#self.call" do
    before do
      allow(BaseService).to receive(:new)
        .and_return(service)
      allow(service).to receive(:call)
    end

    context "when it succeeds" do
      it "is a success" do
        expect(subject.success?).to eq(true)
        expect(subject.failure?).to eq(false)
      end

      context "when the result is a hash" do
        before do
          expect(BaseService).to receive(:new)
            .and_return(service)
          expect(service).to receive(:call)
            .and_return(key: "value")
        end

        it "stores the value" do
          expect(subject.key).to eq("value")
        end
      end
    end

    context "when it fails" do
      before do
        expect(BaseService).to receive(:new)
          .and_return(service)
        expect(service).to receive(:call)
          .and_raise(FailedServiceError.new("some error message"))
      end

      it "is a failure" do
        expect(subject.success?).to eq(false)
        expect(subject.failure?).to eq(true)
      end

      it "stores the error message" do
        expect(subject.errors).to include("some error message")
      end
    end
  end
end
