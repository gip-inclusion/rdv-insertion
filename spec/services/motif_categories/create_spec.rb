describe MotifCategories::Create do
  subject do
    described_class.call(motif_category: motif_category)
  end

  let!(:motif_category) { build(:motif_category) }

  describe "#call" do
    before do
      allow(RdvSolidaritesApi::CreateMotifCategory).to receive(:call)
        .and_return(OpenStruct.new(success?: true))
    end

    it "is a success" do
      is_a_success
    end

    it "tries to create a motif category on rdvs" do
      expect(RdvSolidaritesApi::CreateMotifCategory).to receive(:call)
        .with(
          motif_category_attributes:
            motif_category.symbolized_attributes.slice(*MotifCategory::SHARED_ATTRIBUTES_WITH_RDV_SOLIDARITES)
        )
      subject
    end

    it "saves the motif category in db" do
      subject
      expect(motif_category).to be_persisted
    end

    context "when a required attribute is missing" do
      let!(:motif_category) { build(:motif_category, name: nil) }

      it "is a failure" do
        is_a_failure
      end

      it "stores the error" do
        expect(subject.errors).to eq(["Name doit être rempli(e)"])
      end

      it "does not save the motif category in db" do
        subject
        expect(motif_category).not_to be_persisted
      end
    end

    context "when the template model supports reminders and subscription is mandatory" do
      let!(:template) { create(:template, model: "atelier_enfants_ados") }

      before do
        motif_category.template = template
      end

      it "is a success" do
        is_a_success
      end
    end

    context "when the motif category creation fails" do
      before do
        allow(RdvSolidaritesApi::CreateMotifCategory).to receive(:call)
          .and_return(OpenStruct.new(errors: ["some error"], success?: false))
      end

      it "is a failure" do
        is_a_failure
      end

      it "stores the error" do
        expect(subject.errors).to eq(["some error"])
      end

      it "does not save the motif category in db" do
        subject
        expect(motif_category).not_to be_persisted
      end
    end
  end
end
