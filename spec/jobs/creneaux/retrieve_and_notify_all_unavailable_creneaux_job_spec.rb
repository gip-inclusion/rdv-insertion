describe Creneaux::RetrieveAndNotifyAllUnavailableCreneauxJob do
  subject { described_class.new.perform }

  describe "#perform" do
    context "when there are agents" do
      let(:departments_count) { 3 }
      let(:organisations_per_department) { 2 }

      before do
        departments_count.times do
          department = create(:department)
          organisations_per_department.times do |_i|
            organisation = create(:organisation, department: department)
            agent = create(:agent)
            organisation.agents << agent
          end
        end
      end

      it "perform Creneaux::RetrieveAndNotifyUnavailableCreneauxJob for all organisations" do
        expect(Creneaux::RetrieveAndNotifyUnavailableCreneauxJob).to receive(:perform_later).exactly(6).times

        subject
      end
    end

    context "when there are no agents" do
      let(:department) { create(:department) }
      let(:organisation) { create(:organisation, department: department) }

      it "does not perform Creneaux::RetrieveAndNotifyUnavailableCreneauxJob" do
        expect(Creneaux::RetrieveAndNotifyUnavailableCreneauxJob).not_to receive(:perform_later)

        subject
      end
    end
  end
end
