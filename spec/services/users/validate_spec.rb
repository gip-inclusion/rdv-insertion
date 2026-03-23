describe Users::Validate, type: :service do
  subject { described_class.call(user: user, organisation: organisation) }

  let!(:department) { create(:department) }
  let!(:organisation) { create(:organisation, department: department) }
  let!(:other_department) { create(:department) }
  let!(:other_org) { create(:organisation, department: other_department) }
  let!(:user) { create(:user, nir: generate_random_nir, france_travail_id: "FT123", organisations: [organisation]) }

  describe "#call" do
    context "when there are no conflicts" do
      it("is a success") { is_a_success }
    end

    context "when a user with the same NIR exists in the same department" do
      let!(:other_user) { create(:user, id: 1395, nir: user.nir, organisations: [organisation]) }

      it("is a failure") { is_a_failure }

      it "returns an error" do
        expect(subject.errors).to include(
          "Un usager avec le même Numéro de sécurité sociale se trouve au sein du département: [1395]"
        )
      end
    end

    context "when a user with the same NIR exists in another department" do
      let!(:other_user) { create(:user, nir: user.nir, organisations: [other_org]) }

      it("is a success") { is_a_success }
    end

    context "when a user with the same france_travail_id exists in the same department" do
      let!(:other_user) { create(:user, id: 1395, france_travail_id: "FT123", organisations: [organisation]) }

      it("is a failure") { is_a_failure }

      it "returns an error" do
        expect(subject.errors).to include(
          "Un usager avec le même ID France Travail se trouve au sein du département: [1395]"
        )
      end
    end

    context "when a user with the same france_travail_id exists in another department" do
      let!(:other_user) { create(:user, france_travail_id: "FT123", organisations: [other_org]) }

      it("is a success") { is_a_success }
    end

    context "when the user is not yet persisted" do
      let!(:user) { build(:user, nir: generate_random_nir) }

      context "when no organisation is passed" do
        subject { described_class.call(user: user) }

        it("is a success") { is_a_success }
      end

      context "when an organisation is passed and a conflict exists in its department" do
        let!(:other_user) { create(:user, id: 1395, nir: user.nir, organisations: [organisation]) }

        it("is a failure") { is_a_failure }

        it "returns an error" do
          expect(subject.errors).to include(
            "Un usager avec le même Numéro de sécurité sociale se trouve au sein du département: [1395]"
          )
        end
      end
    end

    context "when updating a persisted user" do
      context "when the user previously had an email and it gets removed" do
        let!(:user) do
          create(:user, email: "test@example.com", nir: nil, department_internal_id: nil,
                        phone_number: nil, affiliation_number: nil, organisations: [organisation])
        end

        before { user.email = nil }

        it("is a failure") { is_a_failure }

        it "returns an error" do
          expect(subject.errors).to include("Impossible de retirer tous les identifiants d'un usager")
        end
      end

      context "when the user previously had affiliation_number + role and role gets removed" do
        let!(:user) do
          create(:user, affiliation_number: "1234", role: "demandeur", nir: nil, department_internal_id: nil,
                        email: nil, phone_number: nil, organisations: [organisation])
        end

        before { user.role = nil }

        it("is a failure") { is_a_failure }

        it "returns an error" do
          expect(subject.errors).to include("Impossible de retirer tous les identifiants d'un usager")
        end
      end

      context "when the user replaces one identifier with another" do
        let!(:user) do
          create(:user, email: "test@example.com", nir: nil, department_internal_id: nil,
                        phone_number: nil, affiliation_number: nil, organisations: [organisation])
        end

        before do
          user.email = nil
          user.phone_number = "+33612345678"
        end

        it("is a success") { is_a_success }
      end

      context "when the user never had any identifier" do
        let!(:user) do
          create(
            :user, :skip_validate,
            nir: nil, department_internal_id: nil, email: nil, phone_number: nil, affiliation_number: nil,
            role: nil, organisations: [organisation]
          )
        end

        it("is a success") { is_a_success }
      end
    end
  end
end
