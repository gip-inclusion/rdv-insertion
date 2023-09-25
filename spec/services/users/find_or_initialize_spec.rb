describe Users::FindOrInitialize, type: :service do
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
    context "when it finds an user" do
      let!(:user) { create(:user, nir: nir, id: 424) }

      before do
        allow(Users::Find).to receive(:call)
          .with(attributes: attributes, department_id: department_id)
          .and_return(OpenStruct.new(user: user))
      end

      it("is a success") { is_a_success }

      it "returns the found user" do
        expect(subject.user.id).to eq(user.id)
      end

      context "when the found user nir is nil" do
        before { user.update! nir: nil }

        it("is a success") { is_a_success }

        it "returns the found user" do
          expect(subject.user.id).to eq(user.id)
        end
      end

      context "when the found user nir does not match" do
        before { user.update! nir: generate_random_nir }

        it("is a failure") { is_a_failure }

        it "returns the found user with an error" do
          expect(subject.user.id).to eq(user.id)

          expect(subject.errors).to eq(["Le bénéficiaire 424 a les mêmes attributs mais un nir différent"])
        end
      end
    end

    context "when it does not find an user" do
      let!(:new_user) { build(:user) }

      before do
        allow(Users::Find).to receive(:call)
          .with(attributes: attributes, department_id: department_id)
          .and_return(OpenStruct.new(user: nil))
        allow(User).to receive(:new).and_return(new_user)
      end

      it("is a success") { is_a_success }

      it "returns a new user" do
        expect(subject.user).to eq(new_user)
        expect(subject.user.id).to be_nil
      end
    end
  end
end
