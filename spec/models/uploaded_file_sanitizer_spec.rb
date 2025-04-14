describe UploadedFileSanitizer do
  let(:valid_file) do
    instance_double("ActionDispatch::Http::UploadedFile", original_filename: "valid.pdf",
                                                          content_type: "application/pdf",
                                                          size: 1.megabyte, path: "valid_path")
  end
  let(:invalid_file) do
    instance_double("ActionDispatch::Http::UploadedFile", original_filename: "invalid.exe",
                                                          content_type: "application/x-msdownload",
                                                          size: 1.megabyte, path: "invalid_path")
  end
  let(:large_file) do
    instance_double("ActionDispatch::Http::UploadedFile", original_filename: "large.pdf",
                                                          content_type: "application/pdf",
                                                          size: 6.megabytes, path: "large_path")
  end

  before do
    allow(File).to receive(:open).and_return(true)
    allow(MimeMagic).to receive(:by_magic).and_return(instance_double("MimeMagic", type: "application/pdf"))
  end

  describe "#sanitize" do
    context "when file is valid" do
      it "returns the uploaded file" do
        expect(described_class.new(valid_file).sanitize).to eq(valid_file)
      end
    end

    context "when file has an invalid extension" do
      it "returns nil and logs the error" do
        expect(Sentry).to receive(:capture_message).with("Invalid file upload", kind_of(Hash))
        expect(described_class.new(invalid_file).sanitize).to be_nil
      end
    end

    context "when file is too large" do
      it "returns nil and logs the error" do
        expect(Sentry).to receive(:capture_message).with("Invalid file upload", kind_of(Hash))
        expect(described_class.new(large_file).sanitize).to be_nil
      end
    end
  end

  describe ".sanitize" do
    it "sanitizes a list of files" do
      files = [valid_file, invalid_file, large_file]
      expect(described_class.sanitize_all(files)).to eq([valid_file])
    end
  end
end
