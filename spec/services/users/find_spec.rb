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
      let!(:user) { create(:user, nir: nir) }

      it "returns the found user" do
        expect(subject.user).to eq(user)
      end
    end

    context "when an user with the same department internal id exists" do
      context "when the user is in the same department" do
        let!(:user) do
          create(
            :user, department_internal_id: department_internal_id, organisations: [other_org_inside_the_department]
          )
        end

        it "returns the found user" do
          expect(subject.user).to eq(user)
        end

        context "for another department" do
          let!(:user) do
            create(
              :user, department_internal_id: department_internal_id,
                     organisations: [other_org_outside_the_department]
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
        create(:user, email: email)
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
        create(:user, phone_number: phone_number)
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
  end

  describe "matching priority order" do
    context "when multiple users match different criteria" do
      let!(:user_nir) { create(:user, nir: nir) }
      let!(:user_department_id) do
        create(
          :user, department_internal_id: department_internal_id,
                 organisations: [other_org_inside_the_department]
        )
      end
      let!(:user_email) { create(:user, email: email, first_name: "JANE") }
      let!(:user_phone) { create(:user, phone_number: phone_number, first_name: "JANE") }
      let!(:user_role_affiliation) do
        create(
          :user, role: role, affiliation_number: affiliation_number,
                 organisations: [other_org_inside_the_department]
        )
      end

      it "prioritizes NIR over all other criteria" do
        expect(subject.user).to eq(user_nir)
      end

      context "when no NIR match exists" do
        let!(:nir) { nil }

        it "prioritizes department internal ID over email, phone, and role/affiliation" do
          expect(subject.user).to eq(user_department_id)
        end

        context "when no department internal ID match exists" do
          let!(:department_internal_id) { nil }

          it "prioritizes email over phone and role/affiliation" do
            expect(subject.user).to eq(user_email)
          end

          context "when no email match exists" do
            let!(:email) { nil }

            it "prioritizes phone number over role/affiliation" do
              expect(subject.user).to eq(user_phone)
            end

            context "when no phone match exists" do
              let!(:phone_number) { nil }

              it "falls back to role/affiliation matching (lowest priority)" do
                expect(subject.user).to eq(user_role_affiliation)
              end
            end
          end
        end
      end
    end
  end
end
