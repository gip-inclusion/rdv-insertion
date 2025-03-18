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

  describe "xss attempt" do
    describe "on request_params" do
      let(:export) do
        build(:csv_export, request_params: {
                no_xss: "coucou",
                xss: "\"><img src=1 onerror=alert(1)>",
                nested: {
                  params: [
                    "\"><img src=1 onerror=alert(1)>",
                    { key: "\"><img src=1 onerror=alert(1)>" },
                    ["\"><img src=1 onerror=alert(1)>"]
                  ],
                  xss: "\"><img src=1 onerror=alert(1)>"
                }
              })
      end

      it "strips all html" do
        export.save!

        expect(export.request_params["no_xss"]).to eq("coucou")
        expect(export.request_params["xss"]).to eq("\">")
        expect(export.request_params.dig("nested", "params")).to eq(["\">", { "key" => "\">" }, ["\">"]])
        expect(export.request_params.dig("nested", "xss")).to eq("\">")
      end
    end
  end
end
