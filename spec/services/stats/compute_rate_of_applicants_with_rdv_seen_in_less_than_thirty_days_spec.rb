describe Stats::ComputeRateOfApplicantsWithRdvSeenInLessThanThirtyDays, type: :service do
  subject { described_class.call(applicants: applicants) }

  let!(:first_day_of_last_month) { 1.month.ago.beginning_of_month }

  let!(:applicants) { Applicant.where(id: [applicant1, applicant2, applicant3, applicant4]) }

  # First applicant : created 1 month ago, has a rdv_seen_delay_in_days present and the delay is less than 30 days
  # => considered as oriented in less than 30 days
  let!(:applicant1) { create(:applicant, created_at: first_day_of_last_month) }
  let!(:rdv_context1) { create(:rdv_context, created_at: first_day_of_last_month, applicant: applicant1) }
  let!(:rdv1) do
    create(:rdv, created_at: first_day_of_last_month, starts_at: (first_day_of_last_month + 2.days), status: "seen")
  end
  let!(:participation1) do
    create(:participation, rdv_context: rdv_context1, applicant: applicant1,
                           rdv: rdv1, created_at: first_day_of_last_month, status: "seen")
  end

  # Second applicant : created 1 month ago, has a rdv_seen_delay_in_days present and the delay is more than 30 days
  # => not considered as oriented in less than 30 days
  let!(:applicant2) { create(:applicant, created_at: first_day_of_last_month) }
  let!(:rdv_context2) { create(:rdv_context, created_at: first_day_of_last_month, applicant: applicant2) }
  let!(:rdv2) do
    create(:rdv, created_at: first_day_of_last_month, starts_at: (first_day_of_last_month + 33.days), status: "seen")
  end
  let!(:participation2) do
    create(:participation, rdv_context: rdv_context2, applicant: applicant2,
                           rdv: rdv2, created_at: first_day_of_last_month, status: "seen")
  end

  # Third applicant : created 1 month ago, has no rdv_seen_delay_in_days present
  # => not considered as oriented in less than 30 days
  let!(:applicant3) { create(:applicant, created_at: first_day_of_last_month) }

  # Fourth applicant : everything okay but created less than 30 days ago
  # not taken into account in the computing
  let!(:applicant4) { create(:applicant, created_at: Time.zone.today) }
  let!(:rdv_context4) { create(:rdv_context, created_at: Time.zone.today, applicant: applicant4) }
  let!(:rdv4) do
    create(:rdv, created_at: Time.zone.today, starts_at: (Time.zone.today + 2.days), status: "seen")
  end
  let!(:participation4) do
    create(:participation, rdv_context: rdv_context4, applicant: applicant4,
                           rdv: rdv4, created_at: Time.zone.today, status: "seen")
  end

  let!(:rdv_context3) { create(:rdv_context, created_at: first_day_of_last_month, applicant: applicant3) }

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
