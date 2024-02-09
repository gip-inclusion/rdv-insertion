describe SendCreneauAvailabilityAlertJob do
  subject { described_class.new.perform }

  describe "#perform" do
    let(:departments_count) { 3 }
    let(:organisations_per_department) { 2 }

    before do
      departments_count.times do
        department = create(:department)
        organisations_per_department.times do
          create(:organisation, department: department)
        end
      end
    end

    it "perform NotifyUnavailableCreneauJob for all organisations" do
      expect(NotifyUnavailableCreneauJob).to receive(:perform_async).exactly(6).times

      subject
    end
  end
end
