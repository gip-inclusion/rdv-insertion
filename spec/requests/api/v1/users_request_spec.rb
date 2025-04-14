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
              "$ref" => "#/components/schemas/user_params"
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
          birth_date: "11/03/1980",
          birth_name: nil,
          address: "13 rue de la République 13001 MARSEILLE",
          department_internal_id: "11111444",
          nir: generate_random_nir,
          referents_to_add: [
            { email: "agentreferent@nomdedomaine.fr" }
          ],
          tags_to_add: [
            { value: "A relancer" }
          ]
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
          birth_date: "29/03/1980",
          birth_name: "AutreNom",
          rights_opening_date: "15/11/2021",
          address: "5 Avenue du Moulin des Baux, 13260 Cassis",
          department_internal_id: "22221111",
          france_travail_id: "22233333",
          nir: generate_random_nir,
          invitation: {
            motif_category: { name: "RSA orientation" }
          },
          tags_to_add: [
            { value: "A relancer" },
            { value: "Prioritaire" }
          ]
        }
      end

      let!(:users_params) do
        { users: [user1_params, user2_params] }
      end

      let!(:agent_referent) { create(:agent, email: "agentreferent@nomdedomaine.fr", organisations: [organisation]) }
      let!(:organisation) do
        create(:organisation, rdv_solidarites_organisation_id:,
                              tags: [create(:tag, value: "A relancer"), create(:tag, value: "Prioritaire")])
      end
      let!(:rdv_solidarites_organisation_id) { 422 }
      let!(:agent) { create(:agent, organisations: [organisation]) }
      let!(:creation_source_attributes) do
        {
          created_through: "rdv_insertion_api",
          created_from_structure_type: "Organisation",
          created_from_structure_id: organisation.id
        }
      end

      before { allow(CreateAndInviteUserJob).to receive(:perform_later) }

      with_authentication

      response 200, "succès" do
        schema "$ref" => "#/components/schemas/success_response"

        run_test! do
          expect(CreateAndInviteUserJob).to have_received(:perform_later)
            .with(
              organisation.id,
              user1_params.merge(creation_source_attributes),
              {},
              {}
            )
          expect(CreateAndInviteUserJob).to have_received(:perform_later)
            .with(
              organisation.id,
              user2_params.except(:invitation).merge(creation_source_attributes),
              {},
              { name: "RSA orientation" }
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
        before do
          users_params[:users][0][:first_name] = ""
        end
      end

      it_behaves_like "an endpoint that returns 422 - unprocessable_entity", "quand les paramètres sont invalide",
                      true do
        before do
          users_params[:users][0][:email] = "invalid@email"
        end
      end

      it_behaves_like "an endpoint that returns 422 - unprocessable_entity", "quand + de 25 usagers sont envoyés",
                      true do
        let!(:users_params) do
          { users: 30.times.map { user1_params } }
        end
      end

      it_behaves_like(
        "an endpoint that returns 422 - unprocessable_entity",
        "quand l'adresse mail du réferent ne correspond à aucun agent enregistré",
        true
      ) do
        before do
          users_params[:users][0][:referents_to_add] = [{ email: "agentnontrouve@nomdedomaine.fr" }]
        end
      end

      it_behaves_like(
        "an endpoint that returns 422 - unprocessable_entity",
        "quand la valeur du tag ne correspond à aucun tag enregistré dans l'organisation",
        true
      ) do
        before do
          users_params[:users][0][:tags_to_add] = [{ value: "TagInexistant" }]
        end
      end

      response 422, "quand le rôle est invalide" do
        schema "$ref" => "#/components/schemas/error_unprocessable_entity"

        let!(:users_params) do
          { users: [user1_params.merge(role: "invalid_role")] }
        end

        run_test! do |response|
          expect(response.status).to eq(422)
          parsed_response = JSON.parse(response.body)
          expect(parsed_response["errors"][0]["error_details"]).to eq(
            "Rôle n'est pas inclus(e) dans la liste"
          )
        end
      end

      response 422, "quand la civilité est invalide" do
        schema "$ref" => "#/components/schemas/error_unprocessable_entity"

        let!(:users_params) do
          { users: [user1_params.merge(title: "invalid_title")] }
        end

        run_test! do |response|
          expect(response.status).to eq(422)
          parsed_response = JSON.parse(response.body)
          expect(parsed_response["errors"][0]["error_details"]).to eq(
            "Civilité n'est pas inclus(e) dans la liste"
          )
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
          birth_date: "11/03/1980",
          birth_name: nil,
          address: "13 rue de la République 13001 MARSEILLE",
          department_internal_id: "11111444",
          nir: generate_random_nir,
          referents_to_add: [
            { email: "agentreferent@nomdedomaine.fr" }
          ],
          tags_to_add: [
            { value: "A relancer" }
          ]
        }
      end

      let!(:user_attributes) do
        {
          **user1_params,
          created_through: "rdv_insertion_api",
          created_from_structure_type: "Organisation",
          created_from_structure_id: organisation.id
        }
      end

      let!(:user_params) do
        {
          user: {
            **user1_params,
            invitation: { motif_category: motif_category_attributes }
          }
        }
      end

      let!(:email_attributes) do
        { format: "email" }
      end
      let!(:sms_attributes) do
        { format: "sms" }
      end

      let!(:agent_referent) { create(:agent, email: "agentreferent@nomdedomaine.fr", organisations: [organisation]) }

      let!(:motif_category_attributes) { { name: "RSA orientation" } }

      let!(:organisation) do
        create(:organisation, rdv_solidarites_organisation_id:, phone_number: "0134499424",
                              tags: [create(:tag, value: "A relancer"), create(:tag, value: "Prioritaire")])
      end
      let!(:rdv_solidarites_organisation_id) { 422 }
      let!(:agent) { create(:agent, organisations: [organisation]) }

      let!(:user) { create(:user, organisations: [organisation], **user_attributes) }

      let!(:email_invitation) { create(:invitation, user:, **email_attributes) }
      let!(:sms_invitation) { create(:invitation, user:, **sms_attributes) }

      before do
        allow(Users::Upsert).to receive(:call)
          .with(user_attributes: user_attributes, organisation:)
          .and_return(OpenStruct.new(success?: true, user:))
        allow(InviteUser).to receive(:call)
          .with(
            user:, organisations: [organisation], motif_category_attributes:,
            invitation_attributes: sms_attributes
          )
          .and_return(OpenStruct.new(success?: true, invitation: sms_invitation))
        allow(InviteUser).to receive(:call)
          .with(
            user:, organisations: [organisation], motif_category_attributes:,
            invitation_attributes: email_attributes
          ).and_return(OpenStruct.new(success?: true, invitation: email_invitation))
      end

      with_authentication

      response 200, "succès" do
        schema type: "object",
               properties: {
                 success: { type: "boolean" },
                 user: {
                   "$ref" => "#/components/schemas/user_with_tags_and_referents"
                 },
                 invitations: {
                   type: "array",
                   items: { "$ref" => "#/components/schemas/invitation" }
                 }
               },
               required: %w[success user invitations]

        run_test! do
          expect(parsed_response_body["success"]).to eq(true)

          expect(parsed_response_body["user"]["tags"]).to include(
            hash_including("value" => "A relancer")
          )
        end
      end

      # rubocop:disable RSpec/EmptyExampleGroup
      context "it does not show all the user attributes depending on organisation type" do
        [:siae, :delegataire_rsa, :autre].each do |organisation_type|
          response(
            200,
            "Pour une organisation de type" \
            "#{I18n.t("activerecord.attributes.organisation.organisation_types.#{organisation_type}")}",
            document: false
          ) do
            let!(:organisation_type) { organisation_type }

            schema type: "object",
                   properties: {
                     success: { type: "boolean" },
                     user: {
                       "$ref" => "#/components/schemas/user_with_referents_for_#{organisation_type}"
                     },
                     invitations: {
                       type: "array",
                       items: { "$ref" => "#/components/schemas/invitation" }
                     }
                   },
                   required: %w[success user invitations]

            run_test!
          end
        end
      end
      # rubocop:enable RSpec/EmptyExampleGroup

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

      it_behaves_like(
        "an endpoint that returns 422 - unprocessable_entity",
        "quand l'adresse mail du réferent ne correspond à aucun agent enregistré",
        true
      ) do
        before { user_params[:user][:referents_to_add] = [{ email: "agentnontrouve@nomdedomaine.fr" }] }
      end

      it_behaves_like(
        "an endpoint that returns 422 - unprocessable_entity",
        "quand la valeur du tag ne correspond à aucun tag enregistré dans l'organisation",
        true
      ) do
        before { user_params[:user][:tags_to_add] = [{ value: "TagInexistant" }] }
      end
    end
  end
end
