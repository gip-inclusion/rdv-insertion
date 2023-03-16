describe Applicants::RemoveFromOrganisation, type: :service do
  subject do
    described_class.call(
      organisation: organisation,
      applicant: applicant,
      rdv_solidarites_session: rdv_solidarites_session
    )
  end

  let!(:organisation) { create(:organisation) }
  let!(:applicant) { create(:applicant, organisations: [organisation]) }
  let!(:rdv_solidarites_session) { instance_double(RdvSolidaritesSession::Base) }

  describe "#call" do
    before do
      allow(RdvSolidaritesApi::DeleteUserProfile).to receive(:call)
        .with(
          user_id: applicant.rdv_solidarites_user_id,
          organisation_id: organisation.rdv_solidarites_organisation_id,
          rdv_solidarites_session: rdv_solidarites_session
        ).and_return(OpenStruct.new(success?: true))
    end

    it "is a success" do
      is_a_success
    end

    it "removes the applicant from the organisation" do
      subject
      expect(applicant.reload.organisations).not_to include(organisation)
    end

    it "deletes the applicant when there is no org attached" do
      subject
      expect(applicant.deleted?).to eq(true)
    end

    context "when the applicant is attached to more than one org" do
      let!(:other_organisation) { create(:organisation) }
      let!(:applicant) { create(:applicant, organisations: [organisation, other_organisation]) }

      it "does not delete the applicant" do
        subject
        expect(applicant.deleted?).to eq(false)
      end
    end

    context "when it fails to remove the org through API" do
      before do
        allow(RdvSolidaritesApi::DeleteUserProfile).to receive(:call)
          .with(
            user_id: applicant.rdv_solidarites_user_id,
            organisation_id: organisation.rdv_solidarites_organisation_id,
            rdv_solidarites_session: rdv_solidarites_session
          ).and_return(OpenStruct.new(success?: false, errors: ["impossible to remove"]))
      end

      it "is a failure" do
        is_a_failure
      end

      it "does not remove the applicant from the organisation" do
        subject
        expect(applicant.reload.organisations).to include(organisation)
      end

      it "outputs an error" do
        expect(subject.errors).to eq(["impossible to remove"])
      end
    end
  end
end
