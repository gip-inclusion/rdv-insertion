describe FindOrInitializeApplicant, type: :service do
  subject do
    described_class.call(
      applicant_params: applicant_params,
      organisation: organisation
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
  # let!(:applicant) do
  #   create(:applicant, applicant_params.merge(organisations: [another_organisation], rdv_solidarites_user_id: 1))
  # end

  let(:applicant) { create(:applicant, organisations: [another_organisation]) }

  describe "#call" do
    before do
      allow(Applicant).to receive(:find_by)
        .and_return(applicant)
      allow(applicant).to receive(:assign_attributes)
    end

    it("is a success") { is_a_success }

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
