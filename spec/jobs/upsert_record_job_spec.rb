describe UpsertRecordJob, type: :job do
  subject do
    described_class.new.perform(class_name, rdv_solidarites_attributes, additional_attributes)
  end

  let(:class_name) { "Rdv" }
  let(:rdv_solidarites_attributes) { { id: 1 } }
  let!(:additional_attributes) do
    {
      participations_attributes: [
        {
          id: nil,
          status: 'unknown',
          applicant_id: applicant_id,
          rdv_solidarites_participation_id: 998
        }
      ],
      organisation_id: organisation_id
    }
  end
  let(:applicant_id) { 23 }
  let(:applicant_ids) { [applicant_id] }

  let(:organisation_id) { 3 }

  describe "#perform" do
    before do
      allow(UpsertRecord).to receive(:call)
    end

    it "calls the upsert service" do
      expect(UpsertRecord).to receive(:call)
        .with(klass: Rdv, rdv_solidarites_attributes: rdv_solidarites_attributes,
              additional_attributes: additional_attributes)
      subject
    end
  end
end
