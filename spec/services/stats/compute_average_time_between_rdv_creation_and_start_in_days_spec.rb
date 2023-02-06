describe Stats::ComputeAverageTimeBetweenRdvCreationAndStartInDays, type: :service do
  subject { described_class.call(rdvs: rdvs) }

  let!(:first_day_of_last_month) { 1.month.ago.beginning_of_month }

  let!(:rdvs) { Rdv.where(id: [rdv1, rdv2]) }

  # First rdv : created 1 month ago, 2 days delay between created_at and starts_at
  let!(:rdv1) { create(:rdv, created_at: first_day_of_last_month, starts_at: (first_day_of_last_month + 2.days)) }

  # Second rdv : created 1 month ago, 4 days delay between created_at and starts_at
  let!(:rdv2) { create(:rdv, created_at: first_day_of_last_month, starts_at: (first_day_of_last_month + 4.days)) }

  describe "#call" do
    let!(:result) { subject }

    it "is a success" do
      expect(result.success?).to eq(true)
    end

    it "renders a float" do
      expect(result.value).to be_a(Float)
    end

    it "computes the average time between the creation of the rdvs and the rdvs date in days" do
      expect(result.value).to eq(3)
    end
  end
end
