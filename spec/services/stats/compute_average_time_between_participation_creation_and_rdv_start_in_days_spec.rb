describe Stats::ComputeAverageTimeBetweenParticipationCreationAndRdvStartInDays, type: :service do
  subject { described_class.call(participations: participations) }

  let!(:first_day_of_last_month) { 1.month.ago.beginning_of_month }

  let!(:participations) { Participation.where(id: [participation1, participation2]) }

  # First rdv : created 1 month ago, 2 days delay between created_at and starts_at
  let!(:rdv1) { create(:rdv, starts_at: (first_day_of_last_month + 2.days)) }
  let!(:participation1) { create(:participation, created_at: first_day_of_last_month, rdv: rdv1) }

  # Second rdv : created 1 month ago, 4 days delay between created_at and starts_at
  let!(:rdv2) { create(:rdv, starts_at: (first_day_of_last_month + 4.days)) }
  let!(:participation2) { create(:participation, created_at: first_day_of_last_month, rdv: rdv2) }

  describe "#call" do
    let!(:result) { subject }

    it "is a success" do
      expect(result.success?).to eq(true)
    end

    it "renders a float" do
      expect(result.value).to be_a(Float)
    end

    it "computes the average time between the creation of the participation and the participation date in days" do
      expect(result.value).to eq(3)
    end
  end
end
