describe Stats::ComputeAverageTimeBetweenInvitationAndRdvInDays, type: :service do
  subject { described_class.call(rdv_contexts: rdv_contexts) }

  let!(:first_day_of_last_month) { 1.month.ago.beginning_of_month }

  let!(:rdv_contexts) { RdvContext.where(id: [rdv_context1, rdv_context2]) }

  # First rdv_context : 2 days delay between first invitation sent_at and first participation creation
  let!(:rdv_context1) { create(:rdv_context, created_at: first_day_of_last_month) }
  let!(:invitation1) do
    create(:invitation, created_at: first_day_of_last_month, sent_at: first_day_of_last_month,
                        rdv_context: rdv_context1)
  end
  let!(:participation1) do
    create(:participation, rdv_context: rdv_context1, created_at: (first_day_of_last_month + 2.days), status: "seen")
  end
  let!(:rdv1) { create(:rdv, created_at: (first_day_of_last_month + 2.days), participations: [participation1]) }

  # Second rdv_context : 4 days delay between first invitation sent_at and first participation creation
  let!(:rdv_context2) { create(:rdv_context, created_at: first_day_of_last_month) }
  let!(:invitation2) do
    create(:invitation, created_at: first_day_of_last_month, sent_at: first_day_of_last_month,
                        rdv_context: rdv_context2)
  end
  let!(:participation2) do
    create(:participation, rdv_context: rdv_context2, created_at: (first_day_of_last_month + 4.days), status: "seen")
  end
  let!(:rdv2) { create(:rdv, created_at: (first_day_of_last_month + 4.days), participations: [participation2]) }

  describe "#call" do
    let!(:result) { subject }

    it "is a success" do
      expect(result.success?).to eq(true)
    end

    it "renders a float" do
      expect(result.value).to be_a(Float)
    end

    it "computes the average time between first invitation and first rdv in days" do
      expect(result.value).to eq(3)
    end
  end
end
