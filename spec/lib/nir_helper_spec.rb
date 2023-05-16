describe NirHelper, type: :module do
  describe "#nir_key" do
    subject { described_class.nir_key(base_nir) }

    context "when the key is one digit" do
      let!(:base_nir) do
        loop do
          base_nir = "180#{10.times.map { rand(1..9) }.join}"
          break base_nir if (97 - (base_nir.first(13).to_i % 97)) < 10
        end
      end

      it "prepends a 0 to the key" do
        expect(subject.length).to eq(2)
        expect(subject.first).to eq("0")
      end
    end
  end
end
