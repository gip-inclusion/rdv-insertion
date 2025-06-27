describe Users::Upsert, type: :service do
  subject do
    described_class.call(user_attributes:, organisation:)
  end

  let!(:user_attributes) { { first_name: "Noah", last_name: "Baumbach" } }
  let!(:organisation) { create(:organisation, department:) }
  let!(:department) { create(:department) }
  let!(:user) { create(:user) }
  let!(:flux_tag) { create(:tag, value: "Flux") }
  let!(:tag_organisation) { create(:tag_organisation, tag: flux_tag, organisation: organisation) }

  describe "#call" do
    before do
      allow(UserPolicy).to receive(:restricted_user_attributes_for)
        .and_return([])
      allow(Users::FindOrInitialize).to receive(:call)
        .with(attributes: user_attributes, department_id: department.id)
        .and_return(OpenStruct.new(success?: true, user:))
      allow(Users::Save).to receive(:call)
        .with(user:, organisation:)
        .and_return(OpenStruct.new(success?: true, user:))
    end

    it "is a success" do
      is_a_success
    end

    it "returns the user" do
      expect(subject.user).to eq(user)
    end

    it "finds or initialize the user" do
      expect(Users::FindOrInitialize).to receive(:call)
        .with(attributes: user_attributes, department_id: department.id)
      subject
    end

    it "assigns the attributes" do
      expect(user).to receive(:assign_attributes)
        .with(user_attributes)
      subject
    end

    it "calls the save service" do
      expect(Users::Save).to receive(:call)
        .with(user:, organisation:)
      subject
    end

    context "when the find or initialize service fails" do
      before do
        allow(Users::FindOrInitialize).to receive(:call)
          .and_return(OpenStruct.new(success?: false, user:, errors: ["something happened"]))
      end

      it "is a failure" do
        is_a_failure
      end

      it "returns the user" do
        expect(subject.user).to eq(user)
      end

      it "returns the error" do
        expect(subject.errors).to eq(["something happened"])
      end

      it "does not save the user" do
        expect(Users::Save).not_to receive(:call)
        subject
      end
    end

    context "when the save service fails" do
      before do
        allow(Users::Save).to receive(:call)
          .with(user:, organisation:)
          .and_return(OpenStruct.new(success?: false, user:, errors: ["something else happened"]))
      end

      it "is a failure" do
        is_a_failure
      end

      it "returns the user" do
        expect(subject.user).to eq(user)
      end

      it "returns the error" do
        expect(subject.errors).to eq(["something else happened"])
      end
    end
  end

  describe "tags assignment during user creation" do
    let!(:agent) { create(:agent, organisations: [organisation]) }

    let(:user_attributes) do
      {
        first_name: "Noah",
        last_name: "Baumbach",
        title: "monsieur",
        affiliation_number: "11111111111",
        role: "demandeur",
        email: "noah.baumbach@gmail.com",
        birth_date: "24/01/1998",
        address: "99999 rue de la République 75027 Paris",
        department_internal_id: "11111111111",
        france_travail_id: "11111111111",
        created_through: "rdv_insertion_api",
        created_from_structure_type: "Organisation",
        created_from_structure_id: organisation.id,
        tags_to_add: [{ value: "Flux" }]
      }
    end

    before do
      allow(UserPolicy).to receive(:restricted_user_attributes_for).and_return([])
      allow_any_instance_of(Users::PushToRdvSolidarites).to receive(:call).and_return(
        OpenStruct.new(success?: true)
      )
    end

    it "assigns tags correctly to newly created user" do
      expect do
        result = described_class.call(user_attributes: user_attributes, organisation: organisation)
        expect(result.success?).to be true
      end.to change(User, :count).by(1)

      created_user = User.last
      expect(created_user.tags.map(&:value)).to include("Flux")
      expect(created_user.organisations).to include(organisation)
    end
  end
end
