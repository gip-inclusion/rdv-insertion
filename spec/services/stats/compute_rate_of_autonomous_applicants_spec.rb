describe Stats::ComputeRateOfAutonomousApplicants, type: :service do
  subject { described_class.call(applicants: applicants, rdvs: rdvs) }

  let!(:first_day_of_last_month) { 1.month.ago.beginning_of_month }

  let!(:applicants) { Applicant.where(id: [applicant1, applicant2, applicant3, applicant4, applicant5]) }
  let!(:rdvs) { Rdv.where(id: [rdv1, rdv2, rdv3]) }

  # First applicant : created 1 month ago, has a rdv taken in autonomy
  let!(:applicant1) { create(:applicant, created_at: first_day_of_last_month) }
  let!(:invitation1) do
    create(:invitation, created_at: first_day_of_last_month, sent_at: first_day_of_last_month,
                        rdv_context: rdv_context1, applicant: applicant1)
  end
  let!(:rdv_context1) { create(:rdv_context, created_at: first_day_of_last_month, applicant: applicant1) }
  let!(:rdv1) do
    create(:rdv, created_at: first_day_of_last_month, created_by: "user")
  end
  let!(:participation1) do
    create(:participation, rdv_context: rdv_context1, applicant: applicant1,
                           rdv: rdv1, created_at: first_day_of_last_month)
  end

  # Second applicant : created 1 month ago, has a rdv not taken in autonomy
  let!(:applicant2) { create(:applicant, created_at: first_day_of_last_month) }
  let!(:invitation2) do
    create(:invitation, created_at: first_day_of_last_month, sent_at: first_day_of_last_month,
                        rdv_context: rdv_context2, applicant: applicant2)
  end
  let!(:rdv_context2) { create(:rdv_context, created_at: first_day_of_last_month, applicant: applicant2) }
  let!(:rdv2) do
    create(:rdv, created_at: first_day_of_last_month, created_by: "agent")
  end
  let!(:participation2) do
    create(:participation, rdv_context: rdv_context2, applicant: applicant2,
                           rdv: rdv2, created_at: first_day_of_last_month)
  end

  # Third applicant : created 1 month ago, has a rdv taken in autonomy
  let!(:applicant3) { create(:applicant, created_at: first_day_of_last_month) }
  let!(:invitation3) do
    create(:invitation, created_at: first_day_of_last_month, sent_at: first_day_of_last_month,
                        rdv_context: rdv_context3, applicant: applicant3)
  end
  let!(:rdv_context3) { create(:rdv_context, created_at: first_day_of_last_month, applicant: applicant3) }
  let!(:rdv3) do
    create(:rdv, created_at: first_day_of_last_month, created_by: "user")
  end
  let!(:participation3) do
    create(:participation, rdv_context: rdv_context3, applicant: applicant3,
                           rdv: rdv3, created_at: first_day_of_last_month)
  end

  # Fourth applicant : created 1 month ago, has not been invited
  # => should not be taken into account to compute the percentage
  let!(:applicant4) { create(:applicant, created_at: first_day_of_last_month) }
  let!(:rdv_context4) { create(:rdv_context, created_at: first_day_of_last_month, applicant: applicant4) }

  # Fifth applicant : created 1 month ago, has been invited but has not take any rdv
  let!(:applicant5) { create(:applicant, created_at: first_day_of_last_month) }
  let!(:invitation5) do
    create(:invitation, created_at: first_day_of_last_month, sent_at: first_day_of_last_month,
                        rdv_context: rdv_context5, applicant: applicant5)
  end
  let!(:rdv_context5) { create(:rdv_context, created_at: first_day_of_last_month, applicant: applicant5) }

  describe "#call" do
    let!(:result) { subject }

    it "is a success" do
      expect(result.success?).to eq(true)
    end

    it "renders a float" do
      expect(result.value).to be_a(Float)
    end

    # Applicant 1 and 3 are ok ; 2 and 5 are not ok ; 4 is not considered
    it "computes the percentage of invited applicants with at least on rdv taken in autonomy" do
      expect(result.value).to eq(50)
    end
  end
end
