describe Applicants::ProcessInput, type: :service do
  subject do
    described_class.call(
      applicant_params: applicant_params,
      department_id: department_id
    )
  end

  let!(:applicant_params) do
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
    before do
      allow(Applicants::FindContactDuplicate).to receive(:call)
        .with(
          email: applicant_params[:email], phone_number: applicant_params[:phone_number],
          role: applicant_params[:role], first_name: applicant_params[:first_name]
        ).and_return(OpenStruct.new(contact_duplicate: nil))
    end

    it("is a success") { is_a_success }

    context "when an applicant with the same nir is found" do
      let!(:applicant) { create(:applicant, nir: nir) }

      it "returns the found applicant" do
        expect(subject.matching_applicant).to eq(applicant)
      end
    end

    context "when an applicant with the same department internal id exists" do
      context "when the applicant is in the same department" do
        let!(:applicant) do
          create(
            :applicant, department_internal_id: department_internal_id, organisations: [other_org_inside_the_department]
          )
        end

        it "returns the found applicant" do
          expect(subject.matching_applicant).to eq(applicant)
        end

        context "for another department" do
          let!(:applicant) do
            create(
              :applicant, department_internal_id: department_internal_id,
                          organisations: [other_org_outside_the_department]
            )
          end

          it("is a success") { is_a_success }

          it "does not return a matching applicant" do
            expect(subject.matching_applicant).to be_nil
          end
        end
      end
    end

    context "when an applicant with the same affiliation_number and role exists" do
      context "when the applicant is in the same department" do
        let!(:applicant) do
          create(
            :applicant, role: role, affiliation_number: affiliation_number,
                        organisations: [other_org_inside_the_department]
          )
        end

        it "returns the found applicant" do
          expect(subject.matching_applicant).to eq(applicant)
        end
      end

      context "for another_department" do
        let!(:applicant) do
          create(
            :applicant, role: role, affiliation_number: affiliation_number,
                        organisations: [other_org_outside_the_department]
          )
        end

        it "does not return a matching applicant" do
          expect(subject.matching_applicant).to be_nil
        end

        it("is a success") { is_a_success }
      end
    end

    context "when an applicant with the same id exists" do
      let!(:applicant) { create(:applicant) }
      let!(:applicant_params) { { encrypted_id: "encrypted_id" } }

      before do
        allow(EncryptionHelper).to receive(:decrypt)
          .with("encrypted_id").and_return(applicant.id)
      end

      it("is a success") { is_a_success }

      it "returns the found applicant" do
        expect(subject.matching_applicant).to eq(applicant)
      end
    end

    context "when the applicant with the same email is found" do
      let!(:applicant) do
        create(:applicant, email: email)
      end

      context "when the first name matches" do
        before { applicant.update! first_name: "JANE" }

        it "returns the found applicant" do
          expect(subject.matching_applicant).to eq(applicant)
        end
      end

      context "when the first name does not match" do
        it "does not return a matching applicant" do
          expect(subject.matching_applicant).to be_nil
        end

        it("is a success") { is_a_success }
      end
    end

    context "when the applicant with the same phone is found" do
      let!(:applicant) do
        create(:applicant, phone_number: phone_number)
      end

      context "when the first name matches" do
        before { applicant.update! first_name: "JANE" }

        it "returns the found applicant" do
          expect(subject.matching_applicant).to eq(applicant)
        end
      end

      context "when the first name does not match" do
        it "does not return a matching applicant" do
          expect(subject.matching_applicant).to be_nil
        end

        it("is a success") { is_a_success }
      end
    end

    context "when no applicant with these attributes exist" do
      it "does not return a matching applicant" do
        expect(subject.matching_applicant).to be_nil
      end
    end
  end

  context "when it finds a contact duplicate" do
    let!(:contact_duplicate) { create(:applicant) }
    let!(:duplicate_attribute) { :email }

    before do
      allow(Applicants::FindContactDuplicate).to receive(:call)
        .with(
          email: applicant_params[:email], phone_number: applicant_params[:phone_number],
          role: applicant_params[:role], first_name: applicant_params[:first_name]
        ).and_return(OpenStruct.new(contact_duplicate: contact_duplicate, duplicate_attribute: duplicate_attribute))
    end

    it("is a failure") { is_a_failure }

    it "returns the contact duplicante and attribute" do
      expect(subject.contact_duplicate).to eq(contact_duplicate)
      expect(subject.duplicate_attribute).to eq(duplicate_attribute)
    end

    it "returns an error" do
      expect(subject.errors).to eq(
        [
          "Un utilisateur avec le même email mais avec un prénom différent a été retrouvé. " \
          "S'il s'agit d'un conjoint, veuillez le préciser sous l'attribut 'rôle'"
        ]
      )
    end
  end

  context "when the nir of the matching is different than the nir input" do
    let!(:applicant) do
      create(:applicant, email: email, first_name: "Jane", nir: generate_random_nir)
    end

    it("is a failure") { is_a_failure }

    it "returns an error" do
      expect(subject.errors).to eq(
        ["La personne #{applicant.id} correspond mais n'a pas le même NIR"]
      )
    end
  end
end
