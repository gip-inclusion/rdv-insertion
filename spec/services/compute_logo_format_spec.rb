describe ComputeLogoFormat, type: :service do
  subject do
    described_class.call(logo_name: logo_name)
  end

  let!(:logo_name) { "drome" }

  describe "#call" do
    it("is a success") { is_a_success }

    it "returns a logo format" do
      expect(subject.format).to eq("svg")
    end

    context "if there is no svg but png" do
      let(:logo_name) { "betagouv-disque" }

      it "returns a png format" do
        expect(subject.format).to eq("png")
      end
    end

    context "if there is no svg nor png but jpg" do
      let(:logo_name) { "europe-s-engage" }

      it "returns a jpg format" do
        expect(subject.format).to eq("jpg")
      end
    end

    context "if there is no svg nor png or jpg logo for this logo name" do
      let(:logo_name) { "random-name" }

      it("is a failure") { is_a_failure }

      it "returns the error message" do
        expect(subject.errors).to eq(["aucun logo n'existe avec ce nom"])
      end
    end
  end
end
