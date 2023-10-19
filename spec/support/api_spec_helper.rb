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

  # rubocop:disable Metrics/AbcSize
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
      description: "Identifiant d'accès (authentification)", example: "martine@demo.rdv-solidarites.fr"
    )

    let(:rdv_solidarites_session) { instance_double(RdvSolidaritesSession::Base) }

    ENV["RDV_SOLIDARITES_URL"] = "http://www.rdv-solidarites-test.localhost"

    before do
      stub_request(:get, "#{ENV['RDV_SOLIDARITES_URL']}/api/v1/auth/validate_token")
        .with(headers: auth_headers.merge({ "Content-Type" => "application/json" }))
        .to_return(body: { "data" => { "uid" => agent.email } }.to_json)
    end
  end
  # rubocop:enable Metrics/AbcSize
end
