describe Applicants::FindContactDuplicate, type: :service do
  subject do
    described_class.call(email: email, phone_number: phone_number, role: role, first_name: first_name)
  end

  let!(:email) { "camille@gouv.fr" }
  let!(:first_name) { "Camille" }
  let!(:role) { nil }
  let!(:phone_number) { "0620022002" }

  describe "#call" do
    context "when no duplicate is found" do
      it("is a success") { is_a_success }

      it "does not return a duplicate" do
        expect(subject.contact_duplicate).to be_nil
        expect(subject.duplicate_attribute).to be_nil
      end
    end

    context "when a duplicate is found" do
      context "by email" do
        let!(:applicant) { create(:applicant, email: "camille@gouv.fr", role: "demandeur", first_name: "camilla") }

        it("is a success") { is_a_success }

        it "does returns a duplicate" do
          expect(subject.contact_duplicate).to eq(applicant)
          expect(subject.duplicate_attribute).to eq(:email)
        end

        context "when we are looking for a conjoint" do
          let!(:role) { "conjoint" }

          it("is a success") { is_a_success }

          it "does not return a duplicate" do
            expect(subject.contact_duplicate).to be_nil
            expect(subject.duplicate_attribute).to be_nil
          end
        end

        context "when the duplicate is a conjoint" do
          let!(:applicant) { create(:applicant, email: "camille@gouv.fr", role: "conjoint", first_name: "camilla") }

          it("is a success") { is_a_success }

          it "does not return a duplicate" do
            expect(subject.contact_duplicate).to be_nil
            expect(subject.duplicate_attribute).to be_nil
          end
        end

        context "when the first name is not given" do
          let!(:first_name) { "" }

          it("is a success") { is_a_success }

          it "does not return a contact duplicate" do
            expect(subject.contact_duplicate).to be_nil
            expect(subject.duplicate_attribute).to be_nil
          end
        end

        context "when the first name is the same" do
          let!(:applicant) { create(:applicant, email: "camille@gouv.fr", role: "demandeur", first_name: "camille") }

          it("is a success") { is_a_success }

          it "does not return a contact duplicate" do
            expect(subject.contact_duplicate).to be_nil
            expect(subject.duplicate_attribute).to be_nil
          end
        end

        context "when the email is not given" do
          let!(:email) { "" }

          it("is a success") { is_a_success }

          it "does not return a contact duplicate" do
            expect(subject.contact_duplicate).to be_nil
            expect(subject.duplicate_attribute).to be_nil
          end
        end
      end

      context "by phone" do
        let!(:applicant) { create(:applicant, phone_number: "+33620022002", role: "demandeur", first_name: "camilla") }

        it("is a success") { is_a_success }

        it "does returns a duplicate" do
          expect(subject.contact_duplicate).to eq(applicant)
          expect(subject.duplicate_attribute).to eq(:phone_number)
        end

        context "when we are looking for a conjoint" do
          let!(:role) { "conjoint" }

          it("is a success") { is_a_success }

          it "does not return a duplicate" do
            expect(subject.contact_duplicate).to be_nil
            expect(subject.duplicate_attribute).to be_nil
          end
        end

        context "when the duplicate is a conjoint" do
          let!(:applicant) { create(:applicant, phone_number: "+33620022002", role: "conjoint", first_name: "camilla") }

          it("is a success") { is_a_success }

          it "does not return a duplicate" do
            expect(subject.contact_duplicate).to be_nil
            expect(subject.duplicate_attribute).to be_nil
          end
        end

        context "when the first name is not given" do
          let!(:first_name) { "" }

          it("is a success") { is_a_success }

          it "does not return a contact duplicate" do
            expect(subject.contact_duplicate).to be_nil
            expect(subject.duplicate_attribute).to be_nil
          end
        end

        context "when the first name is the same" do
          let!(:applicant) do
            create(:applicant, phone_number: "+33620022002", role: "demandeur", first_name: "camille")
          end

          it("is a success") { is_a_success }

          it "does not return a contact duplicate" do
            expect(subject.contact_duplicate).to be_nil
            expect(subject.duplicate_attribute).to be_nil
          end
        end

        context "when the phone number is not given" do
          let!(:phone_number) { "" }

          it("is a success") { is_a_success }

          it "does not return a contact duplicate" do
            expect(subject.contact_duplicate).to be_nil
            expect(subject.duplicate_attribute).to be_nil
          end
        end
      end
    end
  end
end
