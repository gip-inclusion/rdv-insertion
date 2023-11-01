describe UpsertRdvSolidaritesUser, type: :service do
  subject do
    described_class.call(
      user: user, organisation: organisation, rdv_solidarites_session: rdv_solidarites_session
    )
  end

  let!(:rdv_solidarites_organisation_id) { 444 }
  let!(:rdv_solidarites_user_id) { 555 }
  let!(:organisation) do
    create(:organisation, rdv_solidarites_organisation_id: rdv_solidarites_organisation_id)
  end
  let!(:user_attributes) do
    {
      uid: "1234xyz", first_name: "john", last_name: "doe",
      address: "16 rue de la tour", email: "johndoe@example.com", birth_name: "",
      role: "demandeur", birth_date: Date.new(1989, 3, 17), affiliation_number: "aff123", phone_number: "+33612459567"
    }
  end
  let!(:rdv_solidarites_user_attributes) do
    {
      first_name: "john", last_name: "doe",
      address: "16 rue de la tour", email: "johndoe@example.com",
      birth_date: Date.new(1989, 3, 17), affiliation_number: "aff123", phone_number: "+33612459567"
    }
  end
  let!(:user) do
    create(
      :user,
      user_attributes.merge(organisations: [organisation], rdv_solidarites_user_id: rdv_solidarites_user_id)
    )
  end

  let!(:rdv_solidarites_session) { instance_double(RdvSolidaritesSession::Base) }
  let!(:rdv_solidarites_user) { instance_double(RdvSolidarites::User) }

  describe "#call" do
    before do
      allow(RdvSolidaritesApi::CreateUserProfile).to receive(:call)
        .and_return(OpenStruct.new(success?: true))
      allow(RdvSolidaritesApi::RetrieveUser).to receive(:call)
        .and_return(OpenStruct.new(success?: true, user: rdv_solidarites_user))
      allow(RdvSolidaritesApi::UpdateUser).to receive(:call)
        .and_return(OpenStruct.new(success?: true, user: rdv_solidarites_user))
    end

    context "when the rdv_solidarites_user_id is present" do
      before do
        allow(RdvSolidaritesApi::UpdateUser).to receive(:call)
          .and_return(OpenStruct.new(success?: true))
      end

      it "updates the user" do
        expect(RdvSolidaritesApi::UpdateUser).to receive(:call)
          .with(
            user_attributes: rdv_solidarites_user_attributes,
            rdv_solidarites_session: rdv_solidarites_session,
            rdv_solidarites_user_id: rdv_solidarites_user_id
          )
        subject
      end

      it "is a success" do
        is_a_success
      end

      it "stores the rdv_solidarites_user_id" do
        expect(subject.rdv_solidarites_user_id).to eq(rdv_solidarites_user_id)
      end
    end

    context "when the user does not belong to the org" do
      before do
        allow(RdvSolidaritesApi::RetrieveUser).to receive(:call)
          .and_return(OpenStruct.new(success?: false))
      end

      it "assigns the user to the org by creating a user profile" do
        expect(RdvSolidaritesApi::CreateUserProfile).to receive(:call)
          .with(
            user_id: rdv_solidarites_user_id,
            organisation_id: rdv_solidarites_organisation_id,
            rdv_solidarites_session: rdv_solidarites_session
          )
        subject
      end

      it "is a success" do
        is_a_success
      end

      context "when the user profile creation fails" do
        before do
          allow(RdvSolidaritesApi::CreateUserProfile).to receive(:call)
            .and_return(OpenStruct.new(success?: false, errors: ["creation profile error"]))
        end

        it "is a failure" do
          is_a_failure
        end

        it "outputs the errors" do
          expect(subject.errors).to eq(["creation profile error"])
        end
      end
    end

    context "when the rdv_solidarites_user_id is nil" do
      let!(:rdv_solidarites_user_id) { nil }

      before do
        allow(RdvSolidaritesApi::CreateUser).to receive(:call)
          .and_return(OpenStruct.new(success?: true, user: rdv_solidarites_user))
        allow(rdv_solidarites_user).to receive(:id).and_return(42)
      end

      it "creates the user" do
        expect(RdvSolidaritesApi::CreateUser).to receive(:call)
          .with(
            user_attributes: rdv_solidarites_user_attributes.merge(organisation_ids: [rdv_solidarites_organisation_id]),
            rdv_solidarites_session: rdv_solidarites_session
          )
        subject
      end

      it "is a success" do
        is_a_success
      end

      it "stores the rdv_solidarites_user_id" do
        expect(subject.rdv_solidarites_user_id).to eq(42)
      end

      context "when the user has a department_internal_id but no role" do
        before { user.update!(role: nil, department_internal_id: 666) }

        it "creates the user normally, with the email" do
          expect(RdvSolidaritesApi::CreateUser).to receive(:call)
            .with(
              user_attributes:
                rdv_solidarites_user_attributes.merge(organisation_ids: [rdv_solidarites_organisation_id]),
              rdv_solidarites_session: rdv_solidarites_session
            )
          subject
        end
      end

      context "when the user is a conjoint" do
        before { user.update!(role: "conjoint") }

        it "creates the user without the email" do
          expect(RdvSolidaritesApi::CreateUser).to receive(:call)
            .with(
              user_attributes:
                rdv_solidarites_user_attributes.except(:email)
                                               .merge(organisation_ids: [rdv_solidarites_organisation_id]),
              rdv_solidarites_session: rdv_solidarites_session
            )
          subject
        end
      end

      context "when the creation fails" do
        before do
          allow(RdvSolidaritesApi::CreateUser).to receive(:call)
            .and_return(OpenStruct.new(success?: false, errors: ["some creation error"]))
        end

        it "is a failure" do
          is_a_failure
        end

        it "stores the error" do
          expect(subject.errors).to eq(["some creation error"])
        end

        context "when the error is email taken" do
          let!(:existing_user_id) { 42 }

          before do
            allow(RdvSolidaritesApi::CreateUser).to receive(:call)
              .and_return(
                OpenStruct.new(
                  success?: false,
                  error_details: { "email" => [{ "error" => "taken", "id" => existing_user_id }] }
                )
              )
            allow(RdvSolidaritesApi::RetrieveUser).to receive(:call)
              .and_return(OpenStruct.new(success?: false))
          end

          context "when there is no user linked to this user" do
            it "assigns the user to the org by creating a user profile" do
              expect(RdvSolidaritesApi::CreateUserProfile).to receive(:call)
                .with(
                  user_id: 42,
                  organisation_id: rdv_solidarites_organisation_id,
                  rdv_solidarites_session: rdv_solidarites_session
                )
              subject
            end

            it "updates the user" do
              expect(RdvSolidaritesApi::UpdateUser).to receive(:call)
                .with(
                  user_attributes: rdv_solidarites_user_attributes,
                  rdv_solidarites_session: rdv_solidarites_session,
                  rdv_solidarites_user_id: 42
                )
              subject
            end

            it "is a success" do
              is_a_success
            end

            it "stores the rdv_solidarites_user_id" do
              expect(subject.rdv_solidarites_user_id).to eq(42)
            end
          end
        end
      end
    end
  end
end
