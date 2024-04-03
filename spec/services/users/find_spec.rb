describe Users::Find, type: :service do
  subject do
    described_class.call(
      attributes: attributes,
      department_id: department_id
    )
  end

  let!(:attributes) do
    {
      nir: nir,
      email: email,
      phone_number: phone_number,
      first_name: first_name,
      department_internal_id: department_internal_id,
      affiliation_number: affiliation_number,
      role: role
    }
  end
  let!(:nir) { generate_random_nir }
  let!(:email) { "janedoe@gouv.fr" }
  let!(:phone_number) { "+33605050505" }
  let!(:first_name) { "Jane" }
  let!(:department_internal_id) { "6789" }
  let!(:role) { "demandeur" }
  let!(:affiliation_number) { "1234" }
  let!(:organisation) { create(:organisation, department: department) }
  let!(:department) { create(:department, id: department_id) }
  let!(:department_id) { 22 }
  let!(:another_department) { create(:department) }
  let!(:other_org_inside_the_department) { create(:organisation, department: department) }
  let!(:other_org_outside_the_department) { create(:organisation, department: another_department) }

  describe "#call" do
    it("is a success") { is_a_success }

    context "when an user with the same nir is found" do
      let!(:user) { create(:user, role:, nir: nir) }

      it "returns the found user" do
        expect(subject.user).to eq(user)
      end
    end

    context "when an user with the same department internal id exists" do
      context "when the user is in the same department" do
        let!(:user) do
          create(:user, department_internal_id:, organisations: [other_org_inside_the_department], role:)
        end

        it "returns the found user" do
          expect(subject.user).to eq(user)
        end

        context "for another department" do
          let!(:user) do
            create(
              :user, department_internal_id: department_internal_id,
                     organisations: [other_org_outside_the_department],
                     role:
            )
          end

          it("is a success") { is_a_success }

          it "does not return a matching user" do
            expect(subject.user).to be_nil
          end
        end
      end
    end

    context "when an user with the same affiliation_number and role exists" do
      context "when the user is in the same department" do
        let!(:user) do
          create(
            :user, role: role, affiliation_number: affiliation_number,
                   organisations: [other_org_inside_the_department]
          )
        end

        it "returns the found user" do
          expect(subject.user).to eq(user)
        end
      end

      context "for another_department" do
        let!(:user) do
          create(
            :user, role: role, affiliation_number: affiliation_number,
                   organisations: [other_org_outside_the_department]
          )
        end

        it "does not return a matching user" do
          expect(subject.user).to be_nil
        end

        it("is a success") { is_a_success }
      end
    end

    context "when the user with the same email is found" do
      let!(:user) do
        create(:user, role:, email: email)
      end

      context "when the first name matches" do
        before { user.update! first_name: "JANE" }

        it "returns the found user" do
          expect(subject.user).to eq(user)
        end
      end

      context "when the first name does not match" do
        it "does not return a matching user" do
          expect(subject.user).to be_nil
        end

        it("is a success") { is_a_success }
      end
    end

    context "when the user with the same phone is found" do
      let!(:user) do
        create(:user, role:, phone_number: phone_number)
      end

      context "when the first name matches" do
        before { user.update! first_name: "JANE" }

        it "returns the found user" do
          expect(subject.user).to eq(user)
        end
      end

      context "when the first name does not match" do
        it "does not return a matching user" do
          expect(subject.user).to be_nil
        end

        it("is a success") { is_a_success }
      end
    end

    context "when no user with these attributes exist" do
      it "does not return a matching user" do
        expect(subject.user).to be_nil
      end
    end

    context "role matching" do
      let!(:attributes) do
        { email:, phone_number:, role:, first_name: }
      end

      let!(:user) do
        create(:user, first_name:, email:, phone_number:, role: "demandeur")
      end

      context "when role is different" do
        let(:role) { "conjoint" }

        it "does not match" do
          expect(subject.user).to be_nil
        end
      end

      context "when role is missing" do
        it "matches" do
          expect(subject.user).to eq(user)
        end
      end
    end
  end
end
