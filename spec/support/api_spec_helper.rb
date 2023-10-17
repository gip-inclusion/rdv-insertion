module ApiSpecHelper
  def with_examples
    after do |example|
      content = example.metadata[:response][:content] || {}
      example_spec = {
        "application/json" => {
          examples: {
            test_example: {
              value: JSON.parse(response.body, symbolize_names: true)
            }
          }
        }
      }
      example.metadata[:response][:content] = content.deep_merge(example_spec)
    end
  end

  def with_authentication
    security [{ access_token: [], uid: [], client: [] }]

    parameter(
      name: "access-token", in: :header, type: :string,
      description: "Token d'accès (authentification)", example: "SFYBngO55ImjD1HOcv-ivQ"
    )
    parameter(
      name: "client", in: :header, type: :string,
      description: "Clé client d'accès (authentification)", example: "Z6EihQAY9NWsZByfZ47i_Q"
    )
    parameter(
      name: "uid", in: :header, type: :string,
      description: "Identifiant d'accès (authentification)", example: "martine@demo.rdv-solidarites.fr"
    )
  end

  shared_context "an endpoint that returns 401 - unauthorized" do
    response 401, "Renvoie 'unauthorized' quand l'authentification est impossible" do
      let(:"access-token") { "false" }

      schema "$ref" => "#/components/schemas/error_authentication"

      run_test!
    end
  end

  shared_context "an endpoint that returns 403 - forbidden" do |details|
    response 403, "Renvoie 'forbidden' quand #{details}" do
      schema "$ref" => "#/components/schemas/error_forbidden"

      run_test!
    end
  end

  shared_context "an endpoint that returns 404 - not found" do |details|
    response 404, "Renvoie 'not_found' quand #{details}" do
      schema "$ref" => "#/components/schemas/error_not_found"

      run_test!
    end
  end

  shared_context "an endpoint that returns 422 - unprocessable_entity" do |details, document|
    response 422, "Renvoie 'unprocessable_entity' quand #{details}", document: document do
      schema "$ref" => "#/components/schemas/error_unprocessable_entity"

      run_test!
    end
  end
end
