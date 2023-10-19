require "swagger_helper"

describe "Users API", swagger_doc: "v1/api.json" do
  with_examples

  path "api/v1/organisations/{rdv_solidarites_organisation_id}/users/create_and_invite_many" do
    parameter name: :rdv_solidarites_organisation_id, in: :path, type: :string,
              description: "L'id rdv-solidarites d'une organisation",
              example: "403023", required: true

    post "create and invite users" do
      tags "Users"
      consumes "application/json"
      produces "application/json"
      description "Créé et invite une liste d'usagers à prendre rdv.
      La création et l'invitation se font de manière asynchrone."

      parameter name: :users_params, in: :body, required: true, properties: {
        type: "object",
        properties: {
          users: {
            type: "array",
            items: {
              "$ref" => "#/components/schemas/user",
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

      with_authentication

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
          department_internal_id: "11111444"
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

      it_behaves_like "an endpoint that returns 404 - not found", "le rdv n'existe pas" do
        let!(:organisation) { create(:organisation, rdv_solidarites_organisation_id: "some-other-id") }
      end

      it_behaves_like "an endpoint that returns 422 - unprocessable_entity", "quand les paramètres sont incomplets", true do
        before { user1_params[:first_name] = "" }
      end

      it_behaves_like "an endpoint that returns 422 - unprocessable_entity", "quand les paramètres sont invalide", true do
        before { user1_params[:email] = "invalid@email" }
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

      parameter name: :user_params, in: :body, required: true, properties: {
        type: "object",
        properties: {
          user: {
            type: "object",
            properties: {
              "$ref" => "#/components/schemas/user",
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

      let!(:user_params) do
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
          department_internal_id: "11111444"
        }
      end

      let!(:user) { create(:user, **user_params) }

      let!(:mail_invitation) { create(:invitation, user:, format: "email", sent_at: Time.zone.now) }
      let!(:sms_invitation) { create(:invitation, user:, format: "sms", sent_at: Time.zone.now) }


      before do
        allow(Users::Upsert).to receive(:call)
          .and_return(OpenStruct.new(success?: true, user:))
        allow(InviteUser).to receive(:call)
          .and_return(
            OpenStruct.new(success?: true, invitation: sms_invitation),
            OpenStruct.new(success?: true, invitation: mail_invitation)
          )
      end

      response 200, "succès" do
        schema type: "object",
               properties: {
                 success: { type: "boolean" },
                 "$ref" => "#/components/schemas/user",
                 invitations: {
                   type: "array",
                   items: { "$ref" => "#/components/schemas/invitation" }
                 }
               },
               required: %w[success user invitations]
      end
    end
  end
end
