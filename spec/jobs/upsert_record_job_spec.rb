describe UpsertRecordJob, type: :job do
  subject do
    described_class.new.perform(class_name, rdv_solidarites_attributes, additional_attributes)
  end

  let(:class_name) { "Rdv" }
  let(:rdv_solidarites_attributes) { { id: 1 } }
  let(:additional_attributes) { { organisation_id: organisation_id, applicant_ids: applicant_ids } }
  let(:applicant_ids) { [23] }

  let(:organisation_id) { 3 }

  describe "#perform" do
    before do
      allow(UpsertRecord).to receive(:call)
    end

    it "calls the upsert service" do
      expect(UpsertRecord).to receive(:call)
        .with(klass: Rdv, rdv_solidarites_attributes: rdv_solidarites_attributes,
              additional_attributes: { applicant_ids: applicant_ids, organisation_id: organisation_id })
      subject
    end
  end
end
