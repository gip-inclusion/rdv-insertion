module ApiSpecSharedExamples
  shared_context "an endpoint that returns 401 - unauthorized" do
    response 401, "Renvoie 'unauthorized' quand l'authentification est impossible" do
      before do
        stub_request(:get, "#{ENV['RDV_SOLIDARITES_URL']}/api/v1/auth/validate_token")
          .to_return(status: 401)
      end

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
