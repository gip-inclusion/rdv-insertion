describe CategoryConfigurations::Create, type: :service do
  subject do
    described_class.call(category_configuration:)
  end

  let!(:category_configuration) { build(:category_configuration) }

  describe "#call" do
    before do
      allow(RdvSolidaritesApi::CreateMotifCategoryTerritory).to receive(:call)
        .and_return(OpenStruct.new(success?: true))
    end

    it "is a success" do
      is_a_success
    end

    it "tries to create a motif category territory on rdvs" do
      expect(RdvSolidaritesApi::CreateMotifCategoryTerritory).to receive(:call)
        .with(
          motif_category_short_name: category_configuration.motif_category_short_name,
          organisation_id: category_configuration.rdv_solidarites_organisation_id
        )
      subject
    end

    it "saves the category_configuration in db" do
      subject
      expect(category_configuration).to be_persisted
    end

    context "when a required attribute is missing" do
      let!(:category_configuration) { build(:category_configuration, file_configuration_id: nil) }

      it "is a failure" do
        is_a_failure
      end

      it "stores the error" do
        expect(subject.errors).to eq(["Fichier d'import doit exister"])
      end

      it "does not save the category_configuration in db" do
        subject
        expect(category_configuration).not_to be_persisted
      end
    end

    context "when the motif category territory creation fails" do
      before do
        allow(RdvSolidaritesApi::CreateMotifCategoryTerritory).to receive(:call)
          .and_return(OpenStruct.new(errors: ["some error"], success?: false))
      end

      it "is a failure" do
        is_a_failure
      end

      it "stores the error" do
        expect(subject.errors).to eq(["some error"])
      end

      it "does not save the category_configuration in db" do
        subject
        expect(category_configuration).not_to be_persisted
      end
    end

    describe "motif validatity" do
      let(:organisation) { create(:organisation, organisation_type: "delegataire_rsa") }
      let(:category_configuration) do
        build(:category_configuration, organisation: create(:organisation), motif_category:)
      end

      context "when motif is not authorized" do
        let(:motif_category) { create(:motif_category, name: "SIAE", short_name: "siae", motif_category_type: "siae") }

        it "stores the error" do
          expect(subject.errors[0]).to include("La catégorie de motif n'est pas autorisée")
        end
      end

      context "when motif is authorized" do
        let(:motif_category) { create(:motif_category) }

        it "is a success" do
          is_a_success
        end
      end
    end
  end
end
