require "swagger_helper"

describe "Rdv API", swagger_doc: "v1/api.json" do
  with_examples

  path "api/v1/rdvs/{uuid}" do
    get "Retrieves a rdv" do
      let!(:uuid) { SecureRandom.uuid }
      let!(:organisation) { create(:organisation) }
      let!(:rdv) { create(:rdv, uuid:, organisation:) }
      let!(:agent) { create(:agent, organisations: [organisation]) }

      tags "Rdv"
      produces "application/json"
      description "Renvoie les détails du rdv"

      parameter name: :uuid, in: :path, type: :string, description: "L'uuid d'un rdv",
                example: "c5097fb5-4f79-4ef4-b723-f295d888fd98", required: true

      with_authentication

      response 200, "Renvoie le rdv" do
        schema "$ref" => "#/components/schemas/rdv_with_root"

        run_test!

        it { expect(parsed_response_body["rdv"]["id"]).to eq(rdv.id) }
      end

      it_behaves_like "an endpoint that returns 403 - forbidden" do
        let!(:agent) { create(:agent) }
      end

      it_behaves_like "an endpoint that returns 401 - unauthorized"

      it_behaves_like "an endpoint that returns 404 - not found", "le rdv n'existe pas" do
        let!(:rdv) { create(:rdv, uuid: "some-other-uuid", organisation:) }
      end
    end
  end
end
