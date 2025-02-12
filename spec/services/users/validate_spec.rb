describe Users::Validate, type: :service do
  subject do
    described_class.call(user: user)
  end

  let!(:user) do
    create(
      :user,
      first_name: "Ramses",
      email: "ramses2@caramail.com",
      phone_number: "+33782605941",
      affiliation_number: "444222",
      role: "demandeur",
      department_internal_id: "ABBA",
      organisations: [organisation]
    )
  end
  let!(:department) { create(:department) }
  let!(:organisation) { create(:organisation, department: department) }

  describe "#call" do
    context "when it is valid" do
      it("is a success") { is_a_success }
    end

    context "when an user has no identifier" do
      let!(:user) do
        create(
          :user,
          department_internal_id: nil, nir: nil, affiliation_number: nil, phone_number: nil, email: nil
        )
      end

      it("is a failure") { is_a_failure }

      it "returns an error" do
        expect(subject.errors).to include(
          "Il doit y avoir au moins un attribut permettant d'identifier la personne " \
          "(NIR, email, numéro de tel, ID interne, numéro CAF/rôle)"
        )
      end
    end

    context "when an user shares the same department internal id" do
      let!(:other_user) do
        create(
          :user, id: 1395, department_internal_id: "ABBA", organisations: [other_org]
        )
      end

      context "outside the department" do
        let!(:other_org) { create(:organisation, department: create(:department)) }

        it("is a success") { is_a_success }
      end

      context "inside the department" do
        let!(:other_org) { create(:organisation, department: department) }

        it("is a failure") { is_a_failure }

        it "returns an error" do
          expect(subject.errors).to include(
            "Un usager avec le même ID interne au département se trouve au sein du département: [1395]"
          )
        end

        context "when the user does is yet to be persisted and does not belong to the organisation" do
          let!(:user) do
            build(
              :user,
              first_name: "Ramses",
              email: "ramses2@caramail.com",
              phone_number: "+33782605941",
              affiliation_number: "444222",
              role: "demandeur",
              department_internal_id: "ABBA"
            )
          end

          it("is a success") { is_a_success }

          context "when the organisation is passed to the service" do
            subject { described_class.call(user: user, organisation: organisation) }

            it("is a failure") { is_a_failure }

            it "returns an error" do
              expect(subject.errors).to include(
                "Un usager avec le même ID interne au département se trouve au sein du département: [1395]"
              )
            end
          end
        end
      end
    end

    context "when an user shares the same uid" do
      let!(:other_user) do
        create(
          :user, id: 1395, affiliation_number: "444222", role: "demandeur", organisations: [other_org]
        )
      end

      context "outside the department" do
        let!(:other_org) { create(:organisation, department: create(:department)) }

        it("is a success") { is_a_success }
      end

      context "inside the department" do
        let!(:other_org) { create(:organisation, department: department) }

        it("is a failure") { is_a_failure }

        it "returns an error" do
          expect(subject.errors).to include(
            "Un usager avec le même numéro CAF et rôle se trouve au sein du département: [1395]"
          )
        end

        context "when the user does is yet to be persisted and does not belong to the organisation" do
          let!(:user) do
            build(
              :user,
              first_name: "Ramses",
              email: "ramses2@caramail.com",
              phone_number: "+33782605941",
              affiliation_number: "444222",
              role: "demandeur",
              department_internal_id: "ABBA"
            )
          end

          it("is a success") { is_a_success }

          context "when the organisation is passed to the service" do
            subject { described_class.call(user: user, organisation: organisation) }

            it("is a failure") { is_a_failure }

            it "returns an error" do
              expect(subject.errors).to include(
                "Un usager avec le même numéro CAF et rôle se trouve au sein du département: [1395]"
              )
            end
          end
        end
      end
    end

    context "when an user shares the same email" do
      context "with the same first name" do
        let!(:other_user) do
          create(:user, id: 1395, first_name: "ramses", email: "ramses2@caramail.com")
        end

        it("is a failure") { is_a_failure }

        it "returns an error" do
          expect(subject.errors).to include(
            "Un usager avec le même email et même prénom est déjà enregistré: [1395]"
          )
        end
      end

      context "with a different first name" do
        let!(:other_user) do
          create(:user, id: 1395, first_name: "toutankhamon", email: "ramses2@caramail.com")
        end

        it("is a success") { is_a_success }
      end
    end

    context "when an user shares the same phone number" do
      context "with the same first name" do
        let!(:other_user) do
          create(:user, id: 1395, first_name: "ramses", phone_number: "0782605941")
        end

        it("is a failure") { is_a_failure }

        it "returns an error" do
          expect(subject.errors).to include(
            "Un usager avec le même numéro de téléphone et même prénom est déjà enregistré: [1395]"
          )
        end
      end

      context "with a different first name" do
        let!(:other_user) do
          create(:user, id: 1395, first_name: "toutankhamon", phone_number: "0782605941")
        end

        it("is a success") { is_a_success }
      end
    end
  end
end
