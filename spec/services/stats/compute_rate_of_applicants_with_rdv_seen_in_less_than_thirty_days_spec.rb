describe Stats::ComputeRateOfApplicantsWithRdvSeenInLessThanThirtyDays, type: :service do
  subject { described_class.call(applicants: applicants) }

  let(:date) { Time.zone.parse("17/03/2022 12:00") }

  let!(:applicants) { Applicant.where(id: [applicant1, applicant2, applicant3, applicant4]) }

  # First applicant : created 1 month ago, has a rdv_seen_delay_in_days present and the delay is less than 30 days
  # => considered as oriented in less than 30 days
  let!(:applicant1) { create(:applicant, created_at: date) }
  let!(:rdv_context1) { create(:rdv_context, created_at: date, applicant: applicant1) }
  let!(:rdv1) { create(:rdv, created_at: date, starts_at: (date + 2.days), status: "seen") }
  let!(:participation1) do
    create(:participation, rdv_context: rdv_context1, applicant: applicant1,
                           rdv: rdv1, created_at: date, status: "seen")
  end

  # Second applicant : created 1 month ago, has a rdv_seen_delay_in_days present and the delay is more than 30 days
  # => not considered as oriented in less than 30 days
  let!(:applicant2) { create(:applicant, created_at: date) }
  let!(:rdv_context2) { create(:rdv_context, created_at: date, applicant: applicant2) }
  let!(:rdv2) { create(:rdv, created_at: date, starts_at: (date + 33.days), status: "seen") }
  let!(:participation2) do
    create(:participation, rdv_context: rdv_context2, applicant: applicant2,
                           rdv: rdv2, created_at: date, status: "seen")
  end

  # Third applicant : created 1 month ago, has no rdv_seen_delay_in_days present
  # => not considered as oriented in less than 30 days
  let!(:applicant3) { create(:applicant, created_at: date) }

  # Fourth applicant : everything okay but created less than 30 days ago
  # not taken into account in the computing
  let!(:applicant4) { create(:applicant, created_at: Time.zone.today) }
  let!(:rdv_context4) { create(:rdv_context, created_at: Time.zone.today, applicant: applicant4) }
  let!(:rdv4) { create(:rdv, created_at: Time.zone.today, starts_at: (Time.zone.today + 2.days), status: "seen") }
  let!(:participation4) do
    create(:participation, rdv_context: rdv_context4, applicant: applicant4,
                           rdv: rdv4, created_at: Time.zone.today, status: "seen")
  end

  let!(:rdv_context3) { create(:rdv_context, created_at: date, applicant: applicant3) }

  before do
    # this little time travel avoids bugs in the first days of march (because february is less than 30 days)
    travel_to(Time.zone.today + 3.days)
  end

  describe "#call" do
    let!(:result) { subject }

    it "is a success" do
      expect(result.success?).to eq(true)
    end

    it "renders a float" do
      expect(result.value).to be_a(Float)
    end

    it "computes the percentage of applicants with rdv seen in less than 30 days" do
      expect(result.value).to eq(33.33333333333333)
    end
  end
end
