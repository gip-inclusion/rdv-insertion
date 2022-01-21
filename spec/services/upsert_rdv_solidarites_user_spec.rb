describe UpsertRdvSolidaritesUser, type: :service do
  subject do
    described_class.call(
      rdv_solidarites_session: rdv_solidarites_session,
      rdv_solidarites_user_attributes: rdv_solidarites_user_attributes,
      rdv_solidarites_organisation_id: rdv_solidarites_organisation_id, rdv_solidarites_user_id: rdv_solidarites_user_id
    )
  end

  let!(:rdv_solidarites_session) { instance_double(RdvSolidaritesSession) }
  let!(:rdv_solidarites_organisation_id) { 444 }
  let!(:rdv_solidarites_user_id) { 555 }
  let!(:rdv_solidarites_user) { instance_double(RdvSolidarites::User) }
  let!(:rdv_solidarites_user_attributes) { { first_name: "Alain", last_name: "Souchon" } }

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

    context "when the rdv_solidarites_user_id is not passed" do
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
          before do
            allow(RdvSolidaritesApi::CreateUser).to receive(:call)
              .and_return(
                OpenStruct.new(
                  success?: false, error_details: { "email" => [{ "error" => "taken", "id" => 42 }] }
                )
              )
            allow(RdvSolidaritesApi::RetrieveUser).to receive(:call)
              .and_return(OpenStruct.new(success?: false))
          end

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
