module ApiSpecSharedExamples
  shared_context "an endpoint that returns 401 - unauthorized" do
    response 401, "Renvoie 'unauthorized' quand l'authentification est impossible" do
      before do
        allow(rdv_solidarites_session).to receive(:valid?).and_return(false)
      end

      schema "$ref" => "#/components/schemas/error_authentication"

      run_test!
    end
  end

  shared_context "an endpoint that returns 403 - forbidden" do
    response 403, "Renvoie 'forbidden' quand l'agent n'a pas les droits pour effectuer cette action" do
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

  shared_context "an endpoint that returns 422 - unprocessable_entity with details" do |details, document|
    response 422, "Renvoie 'unprocessable_entity' quand #{details}", document: document do
      schema "$ref" => "#/components/schemas/error_unprocessable_entity_with_details"

      run_test!
    end
  end
end
