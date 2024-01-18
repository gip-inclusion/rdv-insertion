describe ZipFile do
  subject { described_class.new(data, filename) }

  let(:data) { "data" }
  let(:filename) { "filename" }

  describe "#compress" do
    it "returns a zip file" do
      subject.compress do |zip|
        expect(zip.mime_type).to eq("application/zip")
        expect(zip.read).to be_a(String)

        Zip::File.open_buffer(zip.read) do |zip_file|
          expect(zip_file).to be_a(Zip::File)
          expect(zip_file.first.name).to eq(filename)
        end
      end
    end

    it "deletes temp files" do
      subject.compress do
        expect(Rails.root.glob("tmp/*#{filename}.zip")).not_to be_empty
      end
      expect(Rails.root.glob("tmp/*#{filename}.zip")).to be_empty
    end
  end
end
