describe Stats::ComputeRateOfApplicantsWithRdvSeenPosteriorToAnInvitation, type: :service do
  subject { described_class.call(invitations: invitations) }

  let!(:invitations) do
    Invitation.where(id: [invitation1, invitation2, invitation3, invitation4, invitation5, invitation6])
  end

  # Applicant 1 : 1 invitation, 1 participation seen after the invitation
  let!(:applicant1) { create(:applicant) }
  let!(:rdv_context1) { create(:rdv_context, applicant: applicant1) }
  let!(:invitation1) { create(:invitation, applicant: applicant1, rdv_context: rdv_context1) }
  let!(:rdv1) { create(:rdv, starts_at: (invitation1.created_at + 2.days), status: "seen") }
  let!(:participation1) do
    create(:participation, rdv: rdv1, applicant: applicant1, rdv_context: rdv_context1,
                           created_at: (invitation1.created_at + 2.days), status: "seen")
  end

  # Applicant 2 : 2 invitations, 1 participation seen after the invitations
  let!(:applicant2) { create(:applicant) }
  let!(:rdv_context2) { create(:rdv_context, applicant: applicant2) }
  let!(:invitation2) { create(:invitation, applicant: applicant2, rdv_context: rdv_context2) }
  let!(:invitation3) { create(:invitation, applicant: applicant2, rdv_context: rdv_context2) }
  let!(:rdv2) { create(:rdv, starts_at: (invitation2.created_at + 2.days), status: "seen") }
  let!(:participation2) do
    create(:participation, rdv: rdv2, applicant: applicant2, rdv_context: rdv_context2,
                           created_at: (invitation2.created_at + 2.days), status: "seen")
  end

  # Applicant 3 : 1 invitation, 1 participation seen before the invitation
  let!(:applicant3) { create(:applicant) }
  let!(:rdv_context3) { create(:rdv_context, applicant: applicant3) }
  let!(:invitation4) { create(:invitation, applicant: applicant3, rdv_context: rdv_context3) }
  let!(:rdv3) { create(:rdv, starts_at: (invitation4.created_at - 2.days), status: "seen") }
  let!(:participation3) do
    create(:participation, rdv: rdv3, applicant: applicant3, rdv_context: rdv_context3,
                           created_at: (invitation4.created_at - 2.days), status: "seen")
  end

  # Applicant 4 : 1 invitation, 1 participation not seen after the invitation
  let!(:applicant4) { create(:applicant) }
  let!(:rdv_context4) { create(:rdv_context, applicant: applicant4) }
  let!(:invitation5) { create(:invitation, applicant: applicant4, rdv_context: rdv_context4) }
  let!(:rdv4) { create(:rdv, starts_at: (invitation5.created_at + 2.days), status: "waiting") }
  let!(:participation4) do
    create(:participation, rdv: rdv4, applicant: applicant4, rdv_context: rdv_context4,
                           created_at: (invitation5.created_at + 2.days), status: "waiting")
  end

  # Applicant 5 : 1 invitation, no participation
  let!(:applicant5) { create(:applicant) }
  let!(:rdv_context5) { create(:rdv_context, applicant: applicant5) }
  let!(:invitation6) { create(:invitation, applicant: applicant5, rdv_context: rdv_context5) }

  describe "#call" do
    let!(:result) { subject }

    it "is a success" do
      expect(result.success?).to eq(true)
    end

    it "renders a float" do
      expect(result.value).to be_a(Float)
    end

    it "computes the percentage of applicants with rdv seen posterior to an invitation" do
      # 6 invitations, 5 applicants, 2 applicants with rdv seen posterior to an invitation
      expect(result.value).to eq(40)
    end
  end
end
