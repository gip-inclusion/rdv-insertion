describe Stats::GlobalStats::UpsertStatJob, type: :service do
  subject do
    described_class.new.perform(structure_type, structure_id, stat_name)
  end

  let(:stat_name) { "users_count" }
  let!(:department) { create(:department) }
  let!(:stat_attributes) do
    { users_count: 3 }
  end
  let!(:stat) { create(:stat, statable_type: "Department", statable_id: department.id) }
  let!(:structure_type) { "Department" }
  let!(:structure_id) { department.id }

  describe "#call" do
    before do
      allow(Stats::GlobalStats::Compute).to receive(:new)
        .and_return(OpenStruct.new(stat_attributes))
      allow(Stat).to receive(:find_or_initialize_by)
        .and_return(stat)
    end

    context "when department" do
      it "finds or initializes stat record" do
        expect(Stat).to receive(:find_or_initialize_by)
          .with(statable_type: "Department", statable_id: department.id)
        subject
      end
    end

    context "when organisation" do
      let!(:organisation) { create(:organisation) }
      let!(:structure_type) { "Organisation" }
      let!(:structure_id) { organisation.id }

      it "finds or initializes stat record" do
        expect(Stat).to receive(:find_or_initialize_by)
          .with(statable_type: "Organisation", statable_id: organisation.id)
        subject
      end
    end

    it "saves the stat record" do
      expect { subject }.to change { stat.reload.users_count }.from(0).to(3)
    end
  end
end
