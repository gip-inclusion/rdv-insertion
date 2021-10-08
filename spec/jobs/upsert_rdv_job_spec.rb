describe UpsertRdvJob, type: :job do
  subject do
    described_class.new.perform(rdv_attributes, applicant_ids, department_id)
  end

  let(:rdv_attributes) { { id: 1 } }
  let(:applicant_ids) { [23] }
  let(:rdv_solidarites_rdv) { instance_double(RdvSolidarites::Rdv) }

  let(:department_id) { 3 }

  describe "#perform" do
    before do
      allow(RdvSolidarites::Rdv).to receive(:new)
        .with(rdv_attributes)
        .and_return(rdv_solidarites_rdv)
      allow(UpsertRecord).to receive(:call)
    end

    it "calls the upsert service" do
      expect(UpsertRecord).to receive(:call)
        .with(klass: Rdv, rdv_solidarites_object: rdv_solidarites_rdv,
              additional_attributes: { applicant_ids: applicant_ids, department_id: department_id })
      subject
    end
  end
end
