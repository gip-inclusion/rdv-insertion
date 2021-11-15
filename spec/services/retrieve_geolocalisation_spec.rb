describe RetrieveGeolocalisation, type: :service do
  subject do
    described_class.call(address: address, department: department)
  end

  let(:address) { "20 Avenue de Ségur, 75007 Paris" }
  let(:department) { create(:department, name: "Paris", number: "75", region: "Île-de-France") }
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
            "label" => "20 Avenue de Ségur 75007 Paris",
            "score" => 0.8470354545454546,
            "housenumber" => "20",
            "id" => "75107_8909_00020",
            "name" => "20 Avenue de Ségur",
            "postcode" => "75007",
            "citycode" => "75107",

            "city" => "Paris",
            "district" => "Paris 7e Arrondissement",
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
          "https://api-adresse.data.gouv.fr/search/",
          { q: address }, { "Content-Type" => "application/json" }
        )
        .and_return(OpenStruct.new(success?: true, body: response_body.to_json))
    end

    it("is a success") { is_a_success }

    it "retrieves the geolocalisation attributes" do
      expect(subject.longitude).to eq(2.308628)
      expect(subject.latitude).to eq(48.850699)
      expect(subject.city_code).to eq("75107")
      expect(subject.street_ban_id).to eq("75107_8909")
    end

    context "when no address is passed" do
      let(:address) { "" }

      it("is a failure") { is_a_failure }

      it "returns the error message" do
        expect(subject.errors).to eq(["an address must be passed!"])
      end
    end

    context "when the request to the api address fails" do
      before do
        allow(Faraday).to receive(:get)
          .with(
            "https://api-adresse.data.gouv.fr/search/",
            { q: address }, { "Content-Type" => "application/json" }
          )
          .and_return(OpenStruct.new(success?: false))
      end

      it("is a failure") { is_a_failure }

      it "returns the error message" do
        expect(subject.errors).to eq(["something happened while requesting geo coordinates"])
      end
    end

    context "when no matching coordinates are found" do
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

      it("is a failure") { is_a_failure }

      it "returns the error message" do
        expect(subject.errors).to eq(["coordinates could not be found"])
      end
    end
  end
end
