describe Stats::ComputePercentageOfNoShow, type: :service do
  subject do
    described_class.call(
      rdvs: Rdv.all.distinct,
      for_focused_month: for_focused_month,
      date: date
    )
  end

  let!(:for_focused_month) { false }
  let!(:date) { nil }

  let!(:first_day_of_last_month) { 1.month.ago.beginning_of_month }
  let!(:first_day_of_other_month) { 2.months.ago.beginning_of_month }

  # First rdv : created 1 month ago, seen status
  let!(:rdv1) { create(:rdv, created_at: first_day_of_last_month, status: "seen") }

  # Second rdv : created 1 month ago, noshow status

  let!(:rdv2) { create(:rdv, created_at: first_day_of_last_month, status: "noshow") }

  # Third rdv : created 2 months ago, seen status
  let!(:rdv3) { create(:rdv, created_at: first_day_of_other_month, status: "seen") }

  # Fourth rdv : created 2 months ago, seen status
  let!(:rdv4) { create(:rdv, created_at: first_day_of_other_month, status: "seen") }

  describe "#call" do
    let!(:result) { subject }

    it "is a success" do
      expect(result.success?).to eq(true)
    end

    it "renders a float" do
      expect(result.data).to be_a(Float)
    end

    it "computes the percentage of noshow for rdvs" do
      expect(result.data).to eq(25)
    end

    context "when for a focused month" do
      let!(:for_focused_month) { true }
      let!(:date) { first_day_of_last_month }
      let!(:result) { subject }

      it "is a success" do
        expect(result.success?).to eq(true)
      end

      it "renders a float" do
        expect(result.data).to be_a(Float)
      end

      # this result should not take the third and fourth rdvs into account
      it "computes the percentage of noshow for rdvs only for the ones created during the focused month" do
        expect(result.data).to eq(50)
      end
    end
  end
end
