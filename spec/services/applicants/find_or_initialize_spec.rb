describe Applicants::FindOrInitialize, type: :service do
  subject do
    described_class.call(
      attributes: attributes,
      department_id: department_id
    )
  end

  let!(:attributes) do
    {
      nir:, email:, first_name:, last_name:
    }
  end

  let!(:nir) { generate_random_nir }
  let!(:email) { "janedoe@beta.gouv.fr" }
  let!(:first_name) { "jane" }
  let!(:last_name) { "doe" }
  let!(:department) { create(:department, id: department_id) }
  let!(:department_id) { 44 }

  describe "#call" do
    context "when it finds an applicant" do
      let!(:applicant) { create(:applicant, nir: nir, id: 424) }

      before do
        allow(Applicants::Find).to receive(:call)
          .with(attributes: attributes, department_id: department_id)
          .and_return(OpenStruct.new(applicant: applicant))
      end

      it("is a success") { is_a_success }

      it "returns the found applicant with the assigned attributes" do
        expect(subject.applicant.id).to eq(applicant.id)
        expect(subject.applicant.email).to eq(email)
        expect(subject.applicant.first_name).to eq(first_name)
        expect(subject.applicant.last_name).to eq(last_name)
      end

      context "when the find applicant nir is nil" do
        before { applicant.update! nir: nil }

        it("is a success") { is_a_success }

        it "returns the found applicant with the assigned attributes" do
          expect(subject.applicant.id).to eq(applicant.id)
          expect(subject.applicant.email).to eq(email)
          expect(subject.applicant.first_name).to eq(first_name)
          expect(subject.applicant.last_name).to eq(last_name)
        end
      end

      context "when the found applicant nir does not match" do
        before { applicant.update! nir: generate_random_nir }

        it("is a failure") { is_a_failure }

        it "returns the found applicant with an error" do
          expect(subject.applicant.id).to eq(applicant.id)

          expect(subject.applicant.email).not_to eq(email)
          expect(subject.applicant.first_name).not_to eq(first_name)
          expect(subject.applicant.last_name).not_to eq(last_name)

          expect(subject.errors).to eq(["Le bénéficiaire 424 a les mêmes attributs mais un nir différent"])
        end
      end
    end

    context "when it does not find an applicant" do
      let!(:new_applicant) { build(:applicant) }

      before do
        allow(Applicants::Find).to receive(:call)
          .with(attributes: attributes, department_id: department_id)
          .and_return(OpenStruct.new(applicant: nil))
        allow(Applicant).to receive(:new).and_return(new_applicant)
      end

      it("is a success") { is_a_success }

      it "returns a new applicant with the assign_attributes" do
        expect(subject.applicant).to eq(new_applicant)
        expect(subject.applicant.id).to be_nil
        expect(subject.applicant.first_name).to eq(first_name)
        expect(subject.applicant.last_name).to eq(last_name)
        expect(subject.applicant.email).to eq(email)
      end
    end
  end
end
