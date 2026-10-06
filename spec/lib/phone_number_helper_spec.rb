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

  describe ".format_phone_number" do
    it "prefixes a Guadeloupe mobile number with +590" do
      expect(described_class.format_phone_number("0690123456")).to eq("+590690123456")
    end

    it "prefixes a Guyane mobile number with +594" do
      expect(described_class.format_phone_number("0694123456")).to eq("+594694123456")
    end

    it "prefixes a Martinique mobile number with +596" do
      expect(described_class.format_phone_number("0696123456")).to eq("+596696123456")
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
