RSpec.describe Anonymizer do
  # this spec will fail when we update RDVI schema but forget to update anonymizer config
  describe "exhaustivity" do
    it "is exhaustive" do
      expect { described_class.validate_exhaustivity! }.not_to raise_error
    end
  end
end
