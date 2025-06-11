describe CreateUserJob do
  subject do
    described_class.new.perform(organisation_id, user_attributes)
  end

  let!(:organisation_id) { 99 }
  let!(:department) { create(:department) }
  let!(:organisation) do
    create(
      :organisation,
      department: department, id: organisation_id, phone_number: "0146292929"
    )
  end
  let!(:user) { create(:user, **user_attributes) }
  let!(:user_attributes) do
    {
      department_internal_id: "1919",
      affiliation_number: "00001",
      role: "conjoint",
      phone_number: "0607070707",
      email: "john.doe@createjob.com",
      first_name: "John",
      last_name: "Doe",
      created_through: "rdv_insertion_api",
      created_from_structure_type: "Organisation",
      created_from_structure_id: organisation_id
    }
  end

  before do
    allow(Users::Upsert).to receive(:call)
      .with(organisation:, user_attributes:)
      .and_return(OpenStruct.new(success?: true, user: user))
  end

  it "upserts the user" do
    expect(Users::Upsert).to receive(:call)
      .with(user_attributes:, organisation: organisation)
    subject
  end

  context "when the save fails" do
    let!(:department_mail) { instance_double("mail") }
    let!(:error_messages) { ["Email invalide"] }

    before do
      allow(Users::Upsert).to receive(:call)
        .and_return(OpenStruct.new(success?: false, errors: error_messages))
      allow(DepartmentMailer).to receive(:create_user_error).and_return(department_mail)
      allow(department_mail).to receive(:deliver_now)
    end

    it "sends an email to the department" do
      expect(DepartmentMailer).to receive(:create_user_error)
        .with(department, user_attributes, error_messages)
      expect(department_mail).to receive(:deliver_now)

      expect { subject }.to raise_error(
        ApplicationJob::FailedServiceError,
        "Error upserting user in CreateUserJob: #{error_messages}"
      )
    end
  end

  context "when organisation does not exist" do
    subject do
      described_class.new.perform(invalid_organisation_id, user_attributes)
    end

    let!(:invalid_organisation_id) { 999_999 }

    it "raises ActiveRecord::RecordNotFound" do
      expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
