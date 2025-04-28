describe RetrieveAddressGeocodingParams, type: :service do
  subject do
    described_class.call(address: address, department_number: department_number)
  end

  let!(:department_number) { "75" }
  let!(:address) { "20 av de Ségur 75007 paris" }
  let!(:parsed_post_code_and_city) { "75007 paris" }
  let!(:parsed_city) { "paris" }
  let(:response_body) do
    {
      "type" => "FeatureCollection",
      "version" => "draft",
      "features" => [
        {
          "type" => "Feature",
          "geometry" => {
            "type" => "Point",
            "coordinates" => [
              2.308628,
              48.850699
            ]
          },
          "properties" => {
            "housenumber" => "20",
            "id" => "75107_8909_00020",
            "name" => "20 Avenue de Ségur",
            "postcode" => "75007",
            "citycode" => "75107",
            "city" => "Paris",
            "context" => "75, Paris, Île-de-France",
            "type" => "housenumber",
            "importance" => 0.69239,
            "street" => "Avenue de Ségur"
          }
        }
      ]
    }
  end

  describe "#call" do
    before do
      allow(Faraday).to receive(:get)
        .with(
          ApiAdresseClient::URL,
          { q: address }, { "Content-Type" => "application/json" }
        )
        .and_return(OpenStruct.new(success?: true, body: response_body.to_json))
    end

    it("is a success") { is_a_success }

    it "retrieves the geolocalisation attributes" do
      expect(subject.geocoding_params).to eq(
        {
          house_number: "20",
          post_code: "75007",
          city_code: "75107",
          city: "Paris",
          street: "Avenue de Ségur",
          street_ban_id: "75107_8909",
          department_number: "75",
          longitude: 2.308628,
          latitude: 48.850699
        }
      )
    end

    context "when no address is passed" do
      let(:address) { "" }

      it("is a success") { is_a_success }

      it "returns no geocoding params" do
        expect(subject.geocoding_params).to be_nil
      end

      it "does not call the api adresse" do
        expect(Faraday).not_to receive(:get)
        subject
      end
    end

    context "when the request to the api address fails" do
      before do
        allow(Faraday).to receive(:get)
          .with(
            ApiAdresseClient::URL,
            { q: address }, { "Content-Type" => "application/json" }
          )
          .and_return(OpenStruct.new(success?: false, body: { "error" => "something" }.to_json))
      end

      it("is a failure") { is_a_failure }

      it "returns the error message" do
        expect(subject.errors).to eq(
          ["Impossible d'appeler l'API addresse!\n response body: #{{ 'error' => 'something' }.to_json}"]
        )
      end
    end

    context "when no matching coordinates are found" do
      before do
        [address, parsed_post_code_and_city, parsed_city].each do |query|
          allow(Faraday).to receive(:get)
            .with(
              ApiAdresseClient::URL,
              { q: query }, { "Content-Type" => "application/json" }
            )
            .and_return(OpenStruct.new(success?: true, body: response_body.to_json))
        end
      end

      let(:response_body) do
        {
          "type" => "FeatureCollection",
          "version" => "draft",
          "features" => [
            {
              "type" => "Feature",
              "geometry" => {
                "type" => "Point",
                "coordinates" => [
                  2.308628,
                  48.850699
                ]
              },
              "properties" => {
                "label" => "Avenue de la Résistance 26150 Die",
                "score" => 0.6414745454545454,
                "id" => "26113_1104",
                "name" => "Avenue de la Résistance",
                "postcode" => "26150",
                "citycode" => "26113",
                "city" => "Die",
                "context" => "26, Drôme, Auvergne-Rhône-Alpes",
                "type" => "street",
                "importance" => 0.45622
              }
            }
          ]
        }
      end

      it("is a success") { is_a_success }

      it "requests the api adresse three times" do
        [address, parsed_post_code_and_city, parsed_city].each do |query|
          expect(Faraday).to receive(:get)
            .with(
              ApiAdresseClient::URL,
              { q: query }, { "Content-Type" => "application/json" }
            )
        end
        subject
      end

      it "returns the error message" do
        expect(subject.geocoding_params).to be_nil
      end
    end

    context "when a response matches the postcode only" do
      let!(:address) { "20 Avenue de Ségur 75007" }
      let!(:parsed_post_code_and_city) { "75007" }

      before do
        [address, parsed_post_code_and_city].each do |query|
          allow(Faraday).to receive(:get)
            .with(
              ApiAdresseClient::URL,
              { q: query }, { "Content-Type" => "application/json" }
            )
            .and_return(OpenStruct.new(success?: true, body: response_body.to_json))
        end
      end

      # parsed_city is an empty string in that case
      it "requests the api adresse two times" do
        [address, parsed_post_code_and_city].each do |query|
          expect(Faraday).to receive(:get)
            .with(
              ApiAdresseClient::URL,
              { q: query }, { "Content-Type" => "application/json" }
            )
        end
        subject
      end

      it("is a success") { is_a_success }

      it "retrieves the geolocalisation attributes" do
        expect(subject.geocoding_params).to eq(
          {
            house_number: "20",
            post_code: "75007",
            city_code: "75107",
            city: "Paris",
            street: "Avenue de Ségur",
            street_ban_id: "75107_8909",
            department_number: "75",
            longitude: 2.308628,
            latitude: 48.850699
          }
        )
      end
    end

    context "when a response matches the department only" do
      let!(:address) { "20 Avenue de Ségur" }

      it("is a success") { is_a_success }

      # it does not request the api with the post code or the city since they are absent
      it "retrieves the geolocalisation attributes" do
        expect(subject.geocoding_params).to eq(
          {
            house_number: "20",
            post_code: "75007",
            city_code: "75107",
            city: "Paris",
            street: "Avenue de Ségur",
            street_ban_id: "75107_8909",
            department_number: "75",
            longitude: 2.308628,
            latitude: 48.850699
          }
        )
      end
    end
  end
end
