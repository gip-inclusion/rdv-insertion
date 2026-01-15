describe FileConfiguration do
  let!(:file_configuration) { build(:file_configuration) }

  context "when no sheet_name" do
    before { file_configuration.sheet_name = nil }

    it { expect(file_configuration).not_to be_valid }
  end

  context "when no first_name_column" do
    before { file_configuration.first_name_column = nil }

    it { expect(file_configuration).not_to be_valid }
  end

  context "when no last_name_column" do
    before { file_configuration.last_name_column = nil }

    it { expect(file_configuration).not_to be_valid }
  end

  context "when columns have identic names" do
    before do
      file_configuration.email_column = "email"
      file_configuration.phone_number_column = "email"
    end

    it { expect(file_configuration).not_to be_valid }
  end
end
