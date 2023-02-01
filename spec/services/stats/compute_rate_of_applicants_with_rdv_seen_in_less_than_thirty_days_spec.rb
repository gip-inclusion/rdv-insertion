describe Stats::ComputeRateOfApplicantsWithRdvSeenInLessThanThirtyDays, type: :service do
  subject do
    described_class.call(
      applicants: Applicant.includes(:rdvs)
                           .preload(rdv_contexts: :rdvs)
                           .distinct,
      for_focused_month: for_focused_month,
      date: date
    )
  end

  let!(:for_focused_month) { false }
  let!(:date) { nil }

  let!(:first_day_of_last_month) { 1.month.ago.beginning_of_month }
  let!(:first_day_of_other_month) { 2.months.ago.beginning_of_month }

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

  # Third applicant : created 2 months ago, has no rdv_seen_delay_in_days present
  # => considered as not oriented in less than 30 days
  let!(:applicant3) { create(:applicant, created_at: first_day_of_other_month) }
  let!(:rdv_context3) { create(:rdv_context, created_at: first_day_of_other_month, applicant: applicant3) }

  # Fourth applicant : created 2 months ago, has a rdv_seen_delay_in_days present and the delay is less than 30 days
  # but the rdv_context is not in the contexts we focus for this stat
  # => should not be taken into account to compute the percentage
  let!(:applicant4) { create(:applicant, created_at: first_day_of_other_month) }
  let!(:rdv_context4) do
    create(:rdv_context, created_at: first_day_of_other_month, applicant: applicant4,
                         motif_category: "rsa_cer_signature")
  end
  let!(:rdv4) do
    create(:rdv, created_at: first_day_of_other_month, starts_at: (first_day_of_other_month + 2.days), status: "seen")
  end
  let!(:participation4) do
    create(:participation, rdv_context: rdv_context4, applicant: applicant4,
                           rdv: rdv4, created_at: first_day_of_other_month, status: "seen")
  end

  describe "#call" do
    let!(:result) { subject }

    it "is a success" do
      expect(result.success?).to eq(true)
    end

    it "renders a float" do
      expect(result.data).to be_a(Float)
    end

    it "computes the percentage of applicants with rdv seen in less than 30 days" do
      expect(result.data).to eq(33.33333333333333)
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

      # this result should not take the third and fourth applicants into account
      it "computes the percentage of applicants created during the focused month with rdv seen in less than 30 days" do
        expect(result.data).to eq(50)
      end
    end
  end
end
