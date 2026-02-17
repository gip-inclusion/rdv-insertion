describe PhoneNumberHelper do
  describe ".mobile?" do
    it "returns true for a french mobile number" do
      expect(described_class.mobile?("+33782605941")).to eq(true)
    end

    it "returns false for a french landline number" do
      expect(described_class.mobile?("0142249062")).to eq(false)
    end

    it "returns nil for a blank number" do
      expect(described_class.mobile?(nil)).to be_nil
    end
  end

  describe ".french_number?" do
    it "returns true for a metropolitan french number" do
      expect(described_class.french_number?("+33782605941")).to eq(true)
    end

    it "returns true for a DROM number (Guadeloupe)" do
      expect(described_class.french_number?("+590690001234")).to eq(true)
    end

    it "returns true for a DROM number (Réunion)" do
      expect(described_class.french_number?("+262692001234")).to eq(true)
    end

    it "returns false for a foreign number" do
      expect(described_class.french_number?("+447911123456")).to eq(false)
    end

    it "returns false for a blank number" do
      expect(described_class.french_number?(nil)).to eq(false)
    end
  end
end
