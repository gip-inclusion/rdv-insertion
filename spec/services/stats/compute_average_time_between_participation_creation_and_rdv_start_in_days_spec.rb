describe Stats::ComputeAverageTimeBetweenParticipationCreationAndRdvStartInDays, type: :service do
  subject { described_class.call(participations: participations) }

  let(:date) { Time.zone.parse("17/03/2022 12:00") }

  let!(:participations) do
    Participation.where(id: [participation1, participation2])
                 .joins(:rdv)
                 .select("participations.id, participations.created_at,
                          participations.status, participations.rdv_id,
                          rdvs.starts_at AS rdv_starts_at")
  end

  # First rdv : created 1 month ago, 2 days delay between created_at and starts_at
  let!(:rdv1) { create(:rdv, starts_at: (date + 2.days)) }
  let!(:participation1) { create(:participation, created_at: date, rdv: rdv1) }

  # Second rdv : created 1 month ago, 4 days delay between created_at and starts_at
  let!(:rdv2) { create(:rdv, starts_at: (date + 4.days)) }
  let!(:participation2) { create(:participation, created_at: date, rdv: rdv2) }

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
