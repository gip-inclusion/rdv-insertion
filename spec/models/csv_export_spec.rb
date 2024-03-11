describe CsvExport do
  describe "validity period" do
    it "expires after 2 days" do
      csv_export = create(:csv_export)
      expect(csv_export.expired?).to be false
      travel 3.days
      expect(csv_export.expired?).to be true
    end
  end

  describe "after_create" do
    it "schedules the expiration job" do
      csv_export = build(:csv_export)
      expect(Exporters::ExpireAttachmentJob).to receive(:perform_in).with(2.days, kind_of(Integer))
      csv_export.save!
    end
  end

  describe "purge!" do
    it "purges the file and updates purged_at" do
      csv_export = create(:csv_export)
      expect(csv_export.file).to be_attached
      csv_export.purge!
      expect(csv_export.file).not_to be_attached
      expect(csv_export.purged_at).to be_present
    end
  end
end
