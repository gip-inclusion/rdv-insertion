describe Stats::ComputeAverageTimeBetweenRdvCreationAndStartInDays, type: :service do
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

  # First rdv : created 1 month ago, 2 days delay between created_at and starts_at
  let!(:rdv1) { create(:rdv, created_at: first_day_of_last_month, starts_at: (first_day_of_last_month + 2.days)) }

  # Second rdv : created 1 month ago, 4 days delay between created_at and starts_at
  let!(:rdv2) { create(:rdv, created_at: first_day_of_last_month, starts_at: (first_day_of_last_month + 4.days)) }

  # Third rdv : created 2 months ago, 6 days delay between created_at and starts_at
  let!(:rdv3) { create(:rdv, created_at: first_day_of_other_month, starts_at: (first_day_of_other_month + 6.days)) }

  describe "#call" do
    let!(:result) { subject }

    it "is a success" do
      expect(result.success?).to eq(true)
    end

    it "renders a float" do
      expect(result.data).to be_a(Float)
    end

    it "computes the average time between the creation of the rdvs and the rdvs date in days" do
      expect(result.data).to eq(4)
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

      # this result should not take the third rdv_context into account
      it "computes the average time between the creation of the rdvs and the rdvs date in days only for " \
         "the rdv_contexts created during the focused month" do
        expect(result.data).to eq(3)
      end
    end
  end
end
