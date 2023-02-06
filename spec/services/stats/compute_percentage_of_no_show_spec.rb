describe Stats::ComputePercentageOfNoShow, type: :service do
  subject { described_class.call(rdvs: rdvs) }

  let!(:first_day_of_last_month) { 1.month.ago.beginning_of_month }

  let!(:rdvs) { Rdv.where(id: [rdv1, rdv2]) }

  # First rdv : created 1 month ago, seen status
  let!(:rdv1) { create(:rdv, created_at: first_day_of_last_month, status: "seen") }

  # Second rdv : created 1 month ago, noshow status

  let!(:rdv2) { create(:rdv, created_at: first_day_of_last_month, status: "noshow") }

  describe "#call" do
    let!(:result) { subject }

    it "is a success" do
      expect(result.success?).to eq(true)
    end

    it "renders a float" do
      expect(result.value).to be_a(Float)
    end

    it "computes the percentage of noshow for rdvs" do
      expect(result.value).to eq(50)
    end
  end
end
