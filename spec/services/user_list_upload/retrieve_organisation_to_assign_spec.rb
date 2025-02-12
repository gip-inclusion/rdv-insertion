describe UserListUpload::RetrieveOrganisationToAssign, type: :service do
  subject { described_class.call(user_row:) }

  let(:address) { "123 Main St" }
  let(:department_number) { "75" }
  let(:department) { create(:department, number: department_number, organisations: [organisation1, organisation2]) }
  let(:user_list_upload) { create(:user_list_upload) }
  let(:organisation1) { create(:organisation) }
  let(:organisation2) { create(:organisation) }

  let(:user_row) do
    create(
      :user_row,
      address: address,
      user_list_upload: user_list_upload
    )
  end

  describe "#call" do
    before do
      allow(user_list_upload).to receive(:department).and_return(department)
      allow(user_list_upload).to receive(:organisations).and_return([organisation1, organisation2])
      allow(RetrieveOrganisationsFromAddress).to receive(:call)
        .with(address: address, department_number: department_number)
        .and_return(OpenStruct.new(success?: true, organisations: matching_organisations))
    end

    context "when matching organisations are found" do
      let(:matching_organisations) { [organisation1] }

      it("is a success") { is_a_success }

      it "returns the matching organisation" do
        expect(subject.organisation).to eq(organisation1)
      end
    end

    context "when no organisations match the address" do
      let(:matching_organisations) { [] }

      it("is a failure") { is_a_failure }

      it "includes the correct error message" do
        expect(subject.errors).to include(
          "Aucune organisation correspondant à l'adresse de cet usager:\n" \
          "row id: #{user_row.id}\n" \
          "user_list_upload_id: #{user_list_upload.id}\n" \
          "address: #{address}\n" \
          "department_number: #{department_number}"
        )
      end
    end

    context "when matching organisations are found but none are assignable" do
      let(:matching_organisations) { [create(:organisation)] }

      it("is a failure") { is_a_failure }

      it "includes the correct error message" do
        expect(subject.errors).to include(
          "Aucune organisation assignable pour cet usager:\n" \
          "row id: #{user_row.id}\n" \
          "user_list_upload_id: #{user_list_upload.id}\n" \
          "address: #{address}\n" \
          "department_number: #{department_number}"
        )
      end
    end

    context "when multiple assignable organisations are found" do
      let(:matching_organisations) { [organisation1, organisation2] }

      it("is a failure") { is_a_failure }

      it "includes the correct error message" do
        expect(subject.errors).to include(
          "Plusieurs organisations possibles pour cet usager:\n" \
          "row id: #{user_row.id}\n" \
          "user_list_upload_id: #{user_list_upload.id}\n" \
          "address: #{address}\n" \
          "department_number: #{department_number}"
        )
      end
    end
  end
end
