describe Stats::ComputeAverageTimeBetweenInvitationAndRdvInDays, type: :service do
  subject do
    described_class.call(
      rdv_contexts: RdvContext.preload(:rdvs, :invitations)
                                           .where.associated(:rdvs)
                                           .with_sent_invitations
                                           .distinct,
      for_focused_month: for_focused_month,
      date: date
    )
  end

  let!(:for_focused_month) { false }
  let!(:date) { nil }

  let!(:first_day_of_last_month) { 1.month.ago.beginning_of_month }
  let!(:first_day_of_other_month) { 2.months.ago.beginning_of_month }

  # First rdv_context : created 1 month ago, 2 days delay between invitation and rdv
  let!(:rdv_context1) { create(:rdv_context, created_at: first_day_of_last_month) }
  let!(:invitation1) do
    create(:invitation, created_at: first_day_of_last_month, sent_at: first_day_of_last_month,
                        rdv_context: rdv_context1)
  end
  let!(:participation1) do
    create(:participation, rdv_context: rdv_context1, created_at: first_day_of_last_month, status: "seen")
  end
  let!(:rdv1) { create(:rdv, created_at: (first_day_of_last_month + 2.days), participations: [participation1]) }

  # Second rdv_context : created 1 month ago, 4 days delay between invitation and rdv
  let!(:rdv_context2) { create(:rdv_context, created_at: first_day_of_last_month) }
  let!(:invitation2) do
    create(:invitation, created_at: first_day_of_last_month, sent_at: first_day_of_last_month,
                        rdv_context: rdv_context2)
  end
  let!(:participation2) do
    create(:participation, rdv_context: rdv_context2, created_at: first_day_of_last_month, status: "seen")
  end
  let!(:rdv2) { create(:rdv, created_at: (first_day_of_last_month + 4.days), participations: [participation2]) }

  # Third rdv_context : created 2 months ago, 6 days delay between invitation and rdv
  let!(:rdv_context3) { create(:rdv_context, created_at: first_day_of_other_month) }
  let!(:invitation3) do
    create(:invitation, created_at: first_day_of_other_month, sent_at: first_day_of_other_month,
                        rdv_context: rdv_context3)
  end
  let!(:participation3) do
    create(:participation, rdv_context: rdv_context3, created_at: first_day_of_other_month, status: "seen")
  end
  let!(:rdv3) { create(:rdv, created_at: (first_day_of_other_month + 6.days), participations: [participation3]) }

  describe "#call" do
    let!(:result) { subject }

    it "is a success" do
      expect(result.success?).to eq(true)
    end

    it "renders a float" do
      expect(result.data).to be_a(Float)
    end

    it "computes the average time between first invitation and first rdv in days" do
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
      it "computes the average time between first invitation and first rdv in days only for " \
         "the rdv_contexts created during the focused month" do
        expect(result.data).to eq(3)
      end
    end
  end
end
