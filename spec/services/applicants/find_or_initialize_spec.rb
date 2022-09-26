describe Applicants::FindOrInitialize, type: :service do
  subject do
    described_class.call(
      department_internal_id: department_internal_id,
      role: role,
      affiliation_number: affiliation_number,
      department_id: department_id
    )
  end

  let!(:department_internal_id) { "6789" }
  let!(:role) { "demandeur" }
  let!(:affiliation_number) { "1234" }
  let!(:organisation) { create(:organisation) }
  let!(:department) { create(:department, id: department_id) }
  let!(:department_id) { 22 }
  let!(:another_department) { create(:department) }

  describe "#call" do
    it("is a success") { is_a_success }

    context "when an applicant with the same department internal id exists" do
      let!(:applicant) { create(:applicant, department: department, department_internal_id: department_internal_id) }

      it "returns the found applicant" do
        expect(subject.applicant).to eq(applicant)
      end

      context "for another department" do
        let!(:applicant) do
          create(:applicant, department: another_department, department_internal_id: department_internal_id)
        end

        it "does not return the existing applicant" do
          expect(subject).not_to eq(applicant)
        end
      end
    end

    context "when an applicant with the same affiliation_number and role exists" do
      let!(:applicant) do
        create(:applicant, department: department, role: role, affiliation_number: affiliation_number)
      end

      it "returns the found applicant" do
        expect(subject.applicant).to eq(applicant)
      end
    end

    context "when no applicant with these attributes exist" do
      let!(:applicant) { build(:applicant) }

      before { allow(Applicant).to receive(:new).and_return(applicant) }

      it "initializes an applicant" do
        expect(Applicant).to receive(:new)
        subject
      end
    end
  end
end
