describe BaseService, type: :service do
  subject { described_class.call }

  let(:service) { instance_double("service") }

  describe "#self.call" do
    before do
      allow(described_class).to receive(:new)
        .and_return(service)
      allow(service).to receive(:call)
      allow(service).to receive(:result)
        .and_return(OpenStruct.new)
    end

    it "calls the #call instance method" do
      expect(service).to receive(:call)
      subject
    end

    context "when it succeeds" do
      it "is a success" do
        expect(subject.success?).to eq(true)
        expect(subject.failure?).to eq(false)
      end
    end

    context "when the result has values" do
      before do
        allow(service).to receive(:result)
          .and_return(OpenStruct.new(key: "value"))
      end

      it "stores the value" do
        expect(subject.key).to eq("value")
      end

      it "is a success" do
        expect(subject.success?).to eq(true)
        expect(subject.failure?).to eq(false)
      end
    end

    context "when the result has errors" do
      before do
        allow(service).to receive(:result)
          .and_return(OpenStruct.new(errors: ["some error occured"]))
      end

      it "is a failure" do
        expect(subject.failure?).to eq(true)
        expect(subject.success?).to eq(false)
      end
    end

    context "when the result is not an OpenStruct" do
      before do
        allow(service).to receive(:result)
          .and_return(nil)
      end

      it "raise an error" do
        expect { subject }.to raise_error(UnexpectedResultBehaviourError)
      end
    end

    context "when it fails" do
      before do
        allow(service).to receive(:call)
          .and_raise(FailedServiceError.new("some error message"))
        allow(service).to receive(:result)
          .and_return(OpenStruct.new(errors: ["another error"]))
      end

      it "is a failure" do
        expect(subject.success?).to eq(false)
        expect(subject.failure?).to eq(true)
      end

      it "stores the error messages" do
        expect(subject.errors).to contain_exactly("some error message", "another error")
      end

      context "when the result errors is not an array" do
        before do
          allow(service).to receive(:result)
            .and_return(OpenStruct.new(errors: nil))
        end

        it "raise an error" do
          expect { subject }.to raise_error(UnexpectedResultBehaviourError)
        end
      end
    end
  end
end
