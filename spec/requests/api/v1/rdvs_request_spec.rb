describe "Rdv API" do
  path "api/v1/rdvs/{uuid}" do
    with_examples

    get "Retrieves a rdv" do
      before { sign_in(agent, for_api: true) }

      with_authentication

      tags "Rdv"
      produces "application/json"
      description "Renvoie les détails du rdv"

      parameter name: "uuid", in: :query, type: :string, description: "L'uuid d'un rdv",
                example: uuid, required: true

      let!(:uuid) { SecureRandom.uuid }
      let!(:rdv) { create(:rdv, uuid:, organisation:) }
      let!(:agent) { create(:agent, organisations: [organisation]) }

      response 200, "Renvoie le rdv" do
        schema "$ref" => "#/components/schemas/rdv_with_root"

        run_test!

        it { expect(parsed_response_body["rdv"]["id"]).to eq(rdv.id) }
      end
    end
  end
end
