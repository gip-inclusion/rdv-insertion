module ApiSpecHelper
  # rubocop:disable Metrics/AbcSize
  def with_examples
    after do |example|
      next if example.metadata[:skip_examples]

      example.metadata[:response][:content] = {
        "application/json" => {
          examples: {
            example.metadata[:example_group][:description] => {
              value: JSON.parse(response.body, symbolize_names: true)
            }
          }
        }
      }

      if request.body&.string.present?
        example.metadata[:operation][:request_examples] ||= []
        request_example = {
          value: JSON.parse(request.body.string, symbolize_names: true),
          name: example.metadata[:response][:description].parameterize.underscore,
          summary: example.metadata[:response][:description]
        }
        example.metadata[:operation][:request_examples] << request_example
      end
    end
  end

  def with_authentication
    security [{ access_token: [], uid: [], client: [] }]

    let!(:auth_headers) do
      {
        "client" => "someclient", "uid" => agent.email, "access-token" => "sometoken"
      }
    end

    let!(:"access-token") { auth_headers["access-token"] }
    let!(:uid) { auth_headers["uid"] }
    let!(:client) { auth_headers["client"] }

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
      description: "Identifiant d'accès (authentification)", example: "amine.dhobb@beta.gouv.fr"
    )

    let(:rdv_solidarites_credentials) { instance_double(RdvSolidaritesCredentials) }

    before do
      stub_request(:get, "#{ENV['RDV_SOLIDARITES_URL']}/api/v1/auth/validate_token")
        .with(headers: auth_headers.merge({ "Content-Type" => "application/json" }))
        .to_return(body: { "data" => { "uid" => agent.email } }.to_json)
    end
  end
  # rubocop:enable Metrics/AbcSize
end
