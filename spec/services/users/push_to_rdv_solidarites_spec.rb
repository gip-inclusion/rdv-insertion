describe Users::PushToRdvSolidarites, type: :service do
  subject do
    described_class.call(user:)
  end

  let!(:agent) { create(:agent, organisations: [organisation]) }
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

  let!(:rdv_solidarites_user) { instance_double(RdvSolidarites::User) }

  describe "#call" do
    before do
      allow_any_instance_of(described_class).to receive(:retrieve_user)
        .and_return(OpenStruct.new(user: OpenStruct.new(notification_email: nil, email: "johndoe@example.com")))
      allow(RdvSolidaritesApi::CreateUserProfiles).to receive(:call)
        .and_return(OpenStruct.new(success?: true))
      allow(RdvSolidaritesApi::CreateReferentAssignations).to receive(:call)
        .and_return(OpenStruct.new(success?: true))
      allow(RdvSolidaritesApi::UpdateUser).to receive(:call)
        .and_return(OpenStruct.new(success?: true, user: rdv_solidarites_user))
      allow(Current).to receive(:agent).and_return(agent)
    end

    context "when the rdv_solidarites_user_id is present" do
      before do
        user.referents = [agent]
      end

      it "assigns the user to the department organisations by creating user profiles on rdvs" do
        expect(RdvSolidaritesApi::CreateUserProfiles).to receive(:call)
          .with(
            rdv_solidarites_user_id: rdv_solidarites_user_id,
            rdv_solidarites_organisation_ids: [rdv_solidarites_organisation_id]
          )
        subject
      end

      it "creates the referents on rdvs" do
        expect(RdvSolidaritesApi::CreateReferentAssignations).to receive(:call)
          .with(
            rdv_solidarites_user_id: rdv_solidarites_user_id,
            rdv_solidarites_agent_ids: [agent.rdv_solidarites_agent_id]
          )
        subject
      end

      it "updates the user" do
        expect(RdvSolidaritesApi::UpdateUser).to receive(:call)
          .with(
            user_attributes: rdv_solidarites_user_attributes,
            rdv_solidarites_user_id: rdv_solidarites_user_id
          )
        subject
      end

      context "when handling email fields" do
        context "when retrieved user has notification_email" do
          before do
            allow_any_instance_of(described_class).to receive(:retrieve_user)
              .and_return(OpenStruct.new(user: OpenStruct.new(notification_email: "johndoe@example.com", email: nil)))
          end

          it "updates the user with notification_email" do
            expect(RdvSolidaritesApi::UpdateUser).to receive(:call)
              .with(
                user_attributes: rdv_solidarites_user_attributes.merge(
                  notification_email: "johndoe@example.com"
                ).except(:email),
                rdv_solidarites_user_id: rdv_solidarites_user_id
              )
            subject
          end
        end

        context "when retrieved user has email field" do
          before do
            allow_any_instance_of(described_class).to receive(:retrieve_user)
              .and_return(OpenStruct.new(user: OpenStruct.new(notification_email: nil, email: "johndoe@example.com")))
          end

          it "updates the user with email field" do
            expect(RdvSolidaritesApi::UpdateUser).to receive(:call)
              .with(
                user_attributes: rdv_solidarites_user_attributes,
                rdv_solidarites_user_id: rdv_solidarites_user_id
              )
            subject
          end
        end

        context "when retrieved user has no email fields" do
          before do
            allow_any_instance_of(described_class).to receive(:retrieve_user)
              .and_return(OpenStruct.new(user: OpenStruct.new(notification_email: nil, email: nil)))
          end

          it "updates the user with notification_email" do
            expect(RdvSolidaritesApi::UpdateUser).to receive(:call)
              .with(
                user_attributes: rdv_solidarites_user_attributes.merge(
                  notification_email: "johndoe@example.com"
                ).except(:email),
                rdv_solidarites_user_id: rdv_solidarites_user_id
              )
            subject
          end
        end
      end

      it "is a success" do
        is_a_success
      end

      it "does not reassign the rdv solidarites user id" do
        subject
        expect(user).not_to receive(:save)
      end

      context "when the referent assignation fails" do
        before do
          allow(RdvSolidaritesApi::CreateReferentAssignations).to receive(:call)
            .and_return(OpenStruct.new(success?: false, errors: ["referent assignation error"]))
        end

        it "is a failure" do
          is_a_failure
        end

        it "outputs the errors" do
          expect(subject.errors).to eq(["referent assignation error"])
        end
      end

      context "when the organisation sync fails" do
        before do
          allow(RdvSolidaritesApi::CreateUserProfiles).to receive(:call)
            .and_return(OpenStruct.new(success?: false, errors: ["user profiles creation error"]))
        end

        it "is a failure" do
          is_a_failure
        end

        it "outputs the errors" do
          expect(subject.errors).to eq(["user profiles creation error"])
        end
      end

      context "when the update fails" do
        before do
          allow(RdvSolidaritesApi::UpdateUser).to receive(:call)
            .and_return(OpenStruct.new(success?: false, errors: ["update error"]))
        end

        it "is a failure" do
          is_a_failure
        end

        it "outputs the errors" do
          expect(subject.errors).to eq(["update error"])
        end
      end
    end

    context "when the rdv_solidarites_user_id is nil" do
      let!(:rdv_solidarites_user_id) { nil }
      let!(:rdv_solidarites_user_attributes) do
        {
          first_name: "john", last_name: "doe",
          address: "16 rue de la tour", notification_email: "johndoe@example.com",
          birth_date: Date.new(1989, 3, 17), affiliation_number: "aff123", phone_number: "+33612459567"
        }
      end

      before do
        allow(RdvSolidaritesApi::CreateUser).to receive(:call)
          .and_return(OpenStruct.new(success?: true, user: rdv_solidarites_user))
        allow(rdv_solidarites_user).to receive(:id).and_return(42)
      end

      it "creates the user" do
        expect(RdvSolidaritesApi::CreateUser).to receive(:call)
          .with(
            user_attributes:
            rdv_solidarites_user_attributes.merge(organisation_ids: [rdv_solidarites_organisation_id])
          )
        subject
      end

      it "assign the rdv solidarites user id" do
        subject
        expect(user.rdv_solidarites_user_id).to eq(42)
      end

      it "tries to save the user in db" do
        expect(user).to receive(:save)
        subject
      end

      it "does not upsert the user profiles" do
        expect(RdvSolidaritesApi::CreateUserProfiles).not_to receive(:call)
        subject
      end

      it "does not upsert the referents" do
        expect(RdvSolidaritesApi::CreateReferentAssignations).not_to receive(:call)
        subject
      end

      context "when the user existed with referents" do
        let!(:referent) { create(:agent) }

        before do
          user.referents = [referent]
        end

        it "upserts the referents" do
          expect(RdvSolidaritesApi::CreateReferentAssignations).to receive(:call)
            .with(
              rdv_solidarites_user_id: 42,
              rdv_solidarites_agent_ids: [referent.rdv_solidarites_agent_id]
            )
          subject
        end
      end

      context "when the user existed in organisations agent does not belong to" do
        let!(:other_org) { create(:organisation) }

        before do
          user.organisations << other_org
        end

        it "upserts the user profiles" do
          expect(RdvSolidaritesApi::CreateUserProfiles).to receive(:call)
            .with(
              rdv_solidarites_user_id: 42,
              rdv_solidarites_organisation_ids: [
                organisation.rdv_solidarites_organisation_id, other_org.rdv_solidarites_organisation_id
              ]
            )
          subject
        end
      end

      context "when the user cannot be saved in db" do
        before do
          allow(user).to receive(:save)
            .and_return(false)
          allow(user).to receive_message_chain(:errors, :full_messages, :to_sentence)
            .and_return("some error")
        end

        it "is a failure" do
          is_a_failure
        end

        it "stores the error" do
          expect(subject.errors).to eq(["some error"])
        end
      end

      context "when the user has a department_internal_id but no role" do
        before { user.update!(role: nil, department_internal_id: 666) }

        it "creates the user normally, with the email" do
          expect(RdvSolidaritesApi::CreateUser).to receive(:call)
            .with(
              user_attributes:
              rdv_solidarites_user_attributes.merge(organisation_ids: [rdv_solidarites_organisation_id])
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
                .merge(organisation_ids: [rdv_solidarites_organisation_id])
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
      end
    end
  end
end
