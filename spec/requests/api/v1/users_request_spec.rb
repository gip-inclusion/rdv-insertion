require "swagger_helper"

describe "Users API", swagger_doc: "v1/api.json" do
  with_examples

  path "api/v1/organisations/{rdv_solidarites_organisation_id}/users/create_and_invite_many" do
    post "create and invite users" do
      tags "User"
      consumes "application/json"
      produces "application/json"
      description "Créé et invite une liste d'usagers à prendre rdv.
      La création et l'invitation se font de manière asynchrone."

      parameter name: :rdv_solidarites_organisation_id, in: :path, type: :string,
                description: "L'id rdv-solidarites d'une organisation",
                example: "403023", required: true

      parameter name: :users_params, in: :body, required: true, schema: {
        type: "object",
        properties: {
          users: {
            type: "array",
            items: {
              "$ref" => "#/components/schemas/user_params",
              invitation: {
                type: "object",
                nullable: true,
                properties: {
                  rdv_solidarites_lieu_id: { type: "string", nullable: true },
                  motif_category: {
                    type: "object",
                    nullable: true,
                    properties: {
                      name: { type: "string" }
                    }
                  }
                }
              }
            }
          },
          required: %w[users]
        }
      }

      let!(:user1_params) do
        {
          first_name: "Didier",
          last_name: "Drogba",
          title: "monsieur",
          affiliation_number: "10492390",
          role: "demandeur",
          email: "didier@drogba.com",
          phone_number: "0782605941",
          birth_date: "11/03/1978",
          address: "13 rue de la République 13001 MARSEILLE",
          department_internal_id: "11111444",
          nir: generate_random_nir
        }
      end

      let!(:user2_params) do
        {
          first_name: "Dimitri",
          last_name: "Payet",
          title: "monsieur",
          affiliation_number: "0782605941",
          role: "conjoint",
          email: "amine.dhobb+testapi2@gmail.com",
          phone_number: "0782605941",
          birth_date: "29/03/1987",
          rights_opening_date: "15/11/2021",
          address: "5 Avenue du Moulin des Baux, 13260 Cassis",
          department_internal_id: "22221111",
          pole_emploi_id: "22233333",
          nir: generate_random_nir,
          invitation: {
            motif_category: { name: "RSA orientation" }
          }
        }
      end
      let!(:users_params) do
        { users: [user1_params, user2_params] }
      end
      let!(:organisation) { create(:organisation, rdv_solidarites_organisation_id:) }
      let!(:rdv_solidarites_organisation_id) { 422 }
      let!(:agent) { create(:agent, organisations: [organisation]) }

      before { allow(CreateAndInviteUserJob).to receive(:perform_async) }

      with_authentication

      response 200, "succès" do
        schema "$ref" => "#/components/schemas/success_response"

        run_test! do
          expect(CreateAndInviteUserJob).to have_received(:perform_async)
            .with(
              organisation.id,
              user1_params,
              {},
              {},
              auth_headers
            )
          expect(CreateAndInviteUserJob).to have_received(:perform_async)
            .with(
              organisation.id,
              user2_params.except(:invitation),
              {},
              { name: "RSA orientation" },
              auth_headers
            )
          expect(parsed_response_body["success"]).to eq(true)
        end
      end

      it_behaves_like "an endpoint that returns 403 - forbidden" do
        let!(:agent) { create(:agent) }
      end

      it_behaves_like "an endpoint that returns 401 - unauthorized"

      it_behaves_like "an endpoint that returns 404 - not found", "l'organisation n'existe pas" do
        let!(:organisation) { create(:organisation, rdv_solidarites_organisation_id: "some-other-id") }
      end

      it_behaves_like "an endpoint that returns 422 - unprocessable_entity", "quand les paramètres sont incomplets",
                      true do
        before { user1_params[:first_name] = "" }
      end

      it_behaves_like "an endpoint that returns 422 - unprocessable_entity", "quand les paramètres sont invalide",
                      true do
        before { user1_params[:email] = "invalid@email" }
      end

      it_behaves_like "an endpoint that returns 422 - unprocessable_entity", "quand + de 25 usagers sont envoyés",
                      true do
        let!(:users_params) do
          { users: 30.times.map { user1_params } }
        end
      end
    end
  end

  path "api/v1/organisations/{rdv_solidarites_organisation_id}/users/create_and_invite" do
    parameter name: :rdv_solidarites_organisation_id, in: :path, type: :string,
              description: "L'id rdv-solidarites d'une organisation",
              example: "403023", required: true

    post "create and invite user" do
      tags "User"
      consumes "application/json"
      produces "application/json"
      description "Créé et invite une liste d'usagers à prendre rdv.
      La création et l'invitation se font de manière synchrone."

      parameter name: :user_params, in: :body, required: true, schema: {
        type: "object",
        properties: {
          user: { "$ref" => "#/components/schemas/user_params" },
          invitation: {
            type: "object",
            nullable: true,
            properties: {
              rdv_solidarites_lieu_id: { type: "string", nullable: true },
              motif_category: {
                type: "object",
                nullable: true,
                properties: {
                  name: { type: "string" }
                }
              }
            }
          },
          required: %w[users]
        }
      }

      let!(:user_params) do
        {
          user: {
            **user_attributes,
            invitation: { motif_category: motif_category_attributes }
          }
        }
      end
      let!(:user_attributes) do
        {
          first_name: "Didier",
          last_name: "Drogba",
          title: "monsieur",
          affiliation_number: "10492390",
          role: "demandeur",
          email: "didier@drogba.com",
          phone_number: "0782605941",
          birth_date: "11/03/1978",
          address: "13 rue de la République 13001 MARSEILLE",
          department_internal_id: "11111444",
          nir: generate_random_nir
        }
      end
      let!(:help_phone_number) { "0134499424" }
      let!(:email_attributes) do
        { help_phone_number:, format: "email" }
      end
      let!(:sms_attributes) do
        { help_phone_number:, format: "sms" }
      end

      let!(:motif_category_attributes) { { name: "RSA orientation" } }

      let!(:organisation) do
        create(:organisation, rdv_solidarites_organisation_id:, phone_number: "0134499424")
      end
      let!(:rdv_solidarites_organisation_id) { 422 }
      let!(:agent) { create(:agent, organisations: [organisation]) }

      let!(:user) { create(:user, **user_attributes) }

      let!(:email_invitation) { create(:invitation, user:, sent_at: Time.zone.now, **email_attributes) }
      let!(:sms_invitation) { create(:invitation, user:, sent_at: Time.zone.now, **sms_attributes) }

      before do
        allow(Users::Upsert).to receive(:call)
          .with(user_attributes:, rdv_solidarites_session:, organisation:)
          .and_return(OpenStruct.new(success?: true, user:))
        allow(InviteUser).to receive(:call)
          .with(
            user:, organisations: [organisation], motif_category_attributes:,
            invitation_attributes: sms_attributes, rdv_solidarites_session:
          )
          .and_return(OpenStruct.new(success?: true, invitation: sms_invitation))
        allow(InviteUser).to receive(:call)
          .with(
            user:, organisations: [organisation], motif_category_attributes:,
            invitation_attributes: email_attributes, rdv_solidarites_session:
          ).and_return(OpenStruct.new(success?: true, invitation: email_invitation))
      end

      with_authentication

      response 200, "succès" do
        schema type: "object",
               properties: {
                 success: { type: "boolean" },
                 user: { "$ref" => "#/components/schemas/user" },
                 invitations: {
                   type: "array",
                   items: { "$ref" => "#/components/schemas/invitation" }
                 }
               },
               required: %w[success user invitations]

        run_test!
      end

      it_behaves_like "an endpoint that returns 403 - forbidden" do
        let!(:agent) { create(:agent) }
      end

      it_behaves_like "an endpoint that returns 401 - unauthorized"

      it_behaves_like "an endpoint that returns 404 - not found", "l'organisation n'existe pas" do
        let!(:organisation) { create(:organisation, rdv_solidarites_organisation_id: "some-other-id") }
      end

      it_behaves_like "an endpoint that returns 422 - unprocessable_entity", "les paramètres sont incomplets", true do
        before { user_params[:user][:first_name] = "" }
      end

      it_behaves_like "an endpoint that returns 422 - unprocessable_entity", "les paramètres sont invalide", true do
        before { user_params[:user][:email] = "invalid@email" }
      end

      it_behaves_like "an endpoint that returns 422 - unprocessable_entity", "l'usager ne peut pas être créé", true do
        before do
          allow(Users::Upsert).to receive(:call)
            .and_return(OpenStruct.new(failure?: true, errors: ["L'usager n'a pas pu être créé"]))
        end
      end

      it_behaves_like "an endpoint that returns 422 - unprocessable_entity", "une invitation ne peut pas être envoyée",
                      true do
        before do
          allow(InviteUser).to receive(:call)
            .and_return(OpenStruct.new(success?: false, errors: ["l'invitation n'a pas pu être délivrée"]))
        end
      end
    end
  end
end
