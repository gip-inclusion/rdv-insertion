describe FindOrInitializeApplicant, type: :service do
  subject do
    described_class.call(
      department_internal_id: applicant_params[:department_internal_id],
      role: applicant_params[:role],
      affiliation_number: applicant_params[:affiliation_number]
    )
  end

  let(:applicant_params) do
    {
      first_name: "john", last_name: "doe", email: "johndoe@example.com",
      affiliation_number: "1234", role: "conjoint", department_internal_id: "6789"
    }
  end
  let!(:organisation) { create(:organisation) }
  let!(:another_organisation) { create(:organisation) }
  let(:applicant) { create(:applicant, organisations: [another_organisation]) }

  describe "#call" do
    before do
      allow(Applicant).to receive(:find_by)
        .and_return(applicant)
    end

    it("is a success") { is_a_success }

    it "returns an applicant" do
      expect(subject.applicant).to eq(applicant)
    end

    context "when department internal id is present" do
      it "search for an applicant with department internal id" do
        expect(Applicant).to receive(:find_by)
          .with(department_internal_id: "6789")
        subject
      end

      context "when an applicant is found" do
        it "does not search for an applicant with role and affiliation number" do
          expect(Applicant).not_to receive(:find_by)
            .with(role: "conjoint", affiliation_number: "1234")
          subject
        end
      end

      context "when no applicant is found" do
        context "when role and affiliation number are present" do
          let(:applicant_params) do
            {
              first_name: "john", last_name: "doe", email: "johndoe@example.com",
              affiliation_number: "1234", role: "conjoint"
            }
          end

          it "searches for an applicant with role and affiliation number" do
            expect(Applicant).to receive(:find_by)
              .with(role: "conjoint", affiliation_number: "1234")
            subject
          end
        end

        context "when role and affiliation number are not present" do
          it "does not search for an applicant with role and affiliation number" do
            expect(Applicant).not_to receive(:find_by)
              .with(role: "conjoint", affiliation_number: "1234")
            subject
          end
        end
      end
    end

    context "when no applicant is found" do
      before do
        allow(Applicant).to receive(:find_by)
          .and_return(nil)
        allow(Applicant).to receive(:new)
      end

      it "initializes an applicant" do
        expect(Applicant).to receive(:new)
        subject
      end
    end
  end
end
