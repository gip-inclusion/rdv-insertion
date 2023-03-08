describe MessagesConfiguration do
  describe "remove_blank_array_fields validation" do
    context "some signature_lines fileds are blank" do
      let(:messages_configuration) do
        create(:messages_configuration, signature_lines: ["some_field", ""])
      end

      it "removes blank fields" do
        expect(messages_configuration.signature_lines).to eq(["some_field"])
      end
    end

    context "some direction_names fileds are blank" do
      let(:messages_configuration) do
        create(:messages_configuration, direction_names: ["some_field", ""])
      end

      it "removes blank fields" do
        expect(messages_configuration.direction_names).to eq(["some_field"])
      end
    end
  end
end
