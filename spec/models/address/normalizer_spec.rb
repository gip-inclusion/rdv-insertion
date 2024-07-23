describe Address::Normalizer do
  subject do
    described_class.new(address).normalize
  end

  let!(:address) { "16 route Saint-Exupéry 03500 Saint-Pourçain-sur-Sioule" }

  it "normalizes the address" do
    expect(subject).to eq("16 rte st exupery 03500 st pourcain sur sioule")
  end
end
