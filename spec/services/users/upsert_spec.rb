describe Users::Upsert, type: :service do
  subject do
    described_class.call(user_attributes:, organisation:, rdv_solidarites_session:)
  end

  let!(:user_attributes) { { first_name: "Noah", last_name: "Baumbach" } }
  let!(:organisation) { create(:organisation, department:) }
  let!(:department) { create(:department) }
  let!(:rdv_solidarites_session) { instance_double(RdvSolidaritesSession::Base) }

  let!(:user) { create(:user) }

  describe "#call" do
    before do
      allow(Users::FindOrInitialize).to receive(:call)
        .with(attributes: user_attributes, department_id: department.id)
        .and_return(OpenStruct.new(success?: true, user:))
      allow(Users::Save).to receive(:call)
        .with(user:, organisation:, rdv_solidarites_session:)
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
        .with(user:, organisation:, rdv_solidarites_session:)
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
          .with(user:, organisation:, rdv_solidarites_session:)
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
end
