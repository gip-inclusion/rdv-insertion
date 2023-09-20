describe Stats::ComputeRateOfAutonomousApplicants, type: :service do
  subject { described_class.call(applicants: applicants) }

  let(:date) { Time.zone.parse("17/03/2022 12:00") }

  let!(:applicants) { Applicant.where(id: [applicant1, applicant2, applicant3, applicant4]) }
  let!(:rdvs) { Rdv.where(id: [rdv1, rdv2, rdv3]) }

  # First applicant : created 1 month ago, has a rdv taken in autonomy
  let!(:applicant1) { create(:applicant, created_at: date) }
  let!(:invitation1) do
    create(:invitation, created_at: date, sent_at: date, rdv_context: rdv_context1, applicant: applicant1)
  end
  let!(:rdv_context1) { create(:rdv_context, created_at: date, applicant: applicant1) }
  let!(:rdv1) { create(:rdv, created_at: date, created_by: "user") }
  let!(:participation1) do
    create(:participation, rdv_context: rdv_context1, applicant: applicant1, rdv: rdv1, created_at: date)
  end

  # Second applicant : created 1 month ago, has a rdv not taken in autonomy
  let!(:applicant2) { create(:applicant, created_at: date) }
  let!(:invitation2) do
    create(:invitation, created_at: date, sent_at: date, rdv_context: rdv_context2, applicant: applicant2)
  end
  let!(:rdv_context2) { create(:rdv_context, created_at: date, applicant: applicant2) }
  let!(:rdv2) { create(:rdv, created_at: date, created_by: "agent") }
  let!(:participation2) do
    create(:participation, rdv_context: rdv_context2, applicant: applicant2, rdv: rdv2, created_at: date)
  end

  # Third applicant : created 1 month ago, has a participation to a rdv taken in autonomy
  let!(:applicant3) { create(:applicant, created_at: date) }
  let!(:invitation3) do
    create(:invitation, created_at: date, sent_at: date, rdv_context: rdv_context3, applicant: applicant3)
  end
  let!(:rdv_context3) { create(:rdv_context, created_at: date, applicant: applicant3) }
  let!(:rdv3) { create(:rdv, created_at: date, created_by: "agent") }
  let!(:participation3) do
    create(:participation, rdv_context: rdv_context3, applicant: applicant3,
                           rdv: rdv3, created_at: date, created_by: "user")
  end

  # Fourth applicant : created 1 month ago, has been invited but has not take any rdv
  let!(:applicant4) { create(:applicant, created_at: date) }
  let!(:invitation4) do
    create(:invitation, created_at: date, sent_at: date, rdv_context: rdv_context4, applicant: applicant4)
  end
  let!(:rdv_context4) { create(:rdv_context, created_at: date, applicant: applicant4) }

  describe "#call" do
    let!(:result) { subject }

    it "is a success" do
      expect(result.success?).to eq(true)
    end

    it "renders a float" do
      expect(result.value).to be_a(Float)
    end

    # Applicant 1 and 3 are ok ; 2 and 5 are not ok ; 4 is not considered
    it "computes the percentage of invited applicants with at least on participation to rdv taken in autonomy" do
      expect(result.value).to eq(50)
    end
  end
end
