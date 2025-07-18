describe MessagesConfiguration do
  describe "signature_lines" do
    context "xss attempt" do
      let(:messages_configuration) do
        build(:messages_configuration, organisation: create(:organisation),
                                       signature_lines: ["\"><img src=1 onerror=alert(1)>", "coucou"])
      end

      it "strips all html tags" do
        messages_configuration.save!
        expect(messages_configuration.signature_lines.first).to eq("\">")
        expect(messages_configuration.signature_lines.last).to eq("coucou")
      end
    end
  end

  describe "remove_blank_array_fields validation" do
    context "some signature_lines fileds are blank" do
      let(:messages_configuration) do
        create(:messages_configuration, organisation: create(:organisation), signature_lines: ["some_field", ""])
      end

      it "removes blank fields" do
        expect(messages_configuration.signature_lines).to eq(["some_field"])
      end
    end

    context "some direction_names fileds are blank" do
      let(:messages_configuration) do
        create(:messages_configuration, organisation: create(:organisation), direction_names: ["some_field", ""])
      end

      it "removes blank fields" do
        expect(messages_configuration.direction_names).to eq(["some_field"])
      end
    end
  end

  describe "signature_image attachment" do
    let(:messages_configuration) { build(:messages_configuration, organisation: create(:organisation)) }

    context "with valid image format" do
      it "accepts PNG images" do
        messages_configuration.signature_image.attach(
          io: File.open("spec/fixtures/logo.png"),
          filename: "signature.png",
          content_type: "image/png"
        )
        expect(messages_configuration).to be_valid
      end

      it "accepts JPEG images" do
        messages_configuration.signature_image.attach(
          io: StringIO.new("fake jpeg content"),
          filename: "signature.jpg",
          content_type: "image/jpeg"
        )
        expect(messages_configuration).to be_valid
      end
    end

    context "with invalid format" do
      it "rejects PDF files" do
        messages_configuration.signature_image.attach(
          io: File.open("spec/fixtures/dummy.pdf"),
          filename: "document.pdf",
          content_type: "application/pdf"
        )
        expect(messages_configuration).not_to be_valid
      end
    end
  end

  describe "#purge_signature_if_requested" do
    let(:messages_configuration) { create(:messages_configuration, organisation: create(:organisation)) }

    context "when signature_image is attached" do
      before do
        messages_configuration.signature_image.attach(
          io: File.open("spec/fixtures/logo.png"),
          filename: "signature.png",
          content_type: "image/png"
        )
      end

      it "purges signature when remove_signature is true" do
        messages_configuration.remove_signature = "true"
        expect(messages_configuration.signature_image).to receive(:purge_later)
        messages_configuration.save!
      end

      it "does not purge when remove_signature is false" do
        messages_configuration.remove_signature = "false"
        expect(messages_configuration.signature_image).not_to receive(:purge_later)
        messages_configuration.save!
      end
    end
  end
end
