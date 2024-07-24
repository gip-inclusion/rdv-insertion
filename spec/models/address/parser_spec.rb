describe Address::Parser do
  subject do
    described_class.new(address)
  end

  context "regular address" do
    let!(:address) { "20 avenue de ségur 75007 Paris" }

    it "parses the address" do
      expect(subject.parsed_street_address).to eq("20 avenue de ségur")
      expect(subject.parsed_post_code_and_city).to eq("75007 Paris")
      expect(subject.parsed_post_code).to eq("75007")
      expect(subject.parsed_city).to eq("Paris")
    end
  end

  context "when the city is missing" do
    let!(:address) { "20 avenue de ségur 75007" }

    it "parses the address" do
      expect(subject.parsed_street_address).to eq("20 avenue de ségur")
      expect(subject.parsed_post_code_and_city).to eq("75007")
      expect(subject.parsed_post_code).to eq("75007")
      expect(subject.parsed_city).to eq("")
    end
  end

  context "when the post code is missing" do
    let!(:address) { "20 avenue de ségur Paris" }

    it "cannot parse the address" do
      expect(subject.parsed_street_address).to be_nil
      expect(subject.parsed_post_code_and_city).to be_nil
      expect(subject.parsed_post_code).to be_nil
      expect(subject.parsed_city).to be_nil
    end
  end

  context "when the post_code is in front" do
    let!(:address) { "75007 Paris Avenue de ségur" }

    it "fails to parse everything correctly" do
      expect(subject.parsed_street_address).to eq("")
      expect(subject.parsed_post_code_and_city).to eq("75007 Paris Avenue de ségur")
      expect(subject.parsed_post_code).to eq("75007")
      expect(subject.parsed_city).to eq("Paris Avenue de ségur")
    end
  end

  context "when the post code is followed by commas" do
    let!(:address) { "20 avenue de ségur, Pyrénées-Atlantiques, 64460, Labatut" }

    it "parses the city accordingly" do
      expect(subject.parsed_city).to eq("Labatut")
    end
  end
end
