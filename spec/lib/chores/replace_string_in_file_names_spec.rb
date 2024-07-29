require Rails.root.join("lib/chores/replace_string_in_file_names")

describe Chores::ReplaceStringInFileNames do
  subject do
    described_class.new(expression_to_replace, replace_with).call
  end

  let(:expression_to_replace) { "organisation" }
  let(:replace_with) { "organization" }

  describe "#call" do
    it "renames all folders and files containing the first expression by replacing it with the second expression" do
      expect(FileUtils).to receive(:mv).with(/rganisation/, /rganization/).at_least(:once)
      subject
    end
  end
end
