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
end
