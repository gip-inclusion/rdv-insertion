describe UserArchivedStatus do
  let!(:user_archived_status) { described_class.new(user, organisations) }
  let(:department) { create(:department) }
  let(:user) { create(:user, organisations: [organisation1, organisation2]) }
  let(:organisation1) { create(:organisation, department:) }
  let(:organisation2) { create(:organisation, department:) }
  let(:organisations) { [organisation1, organisation2] }
  let!(:archive1) { create(:archive, organisation: organisation1, user:) }
  let!(:archive2) { create(:archive, organisation: organisation2, user:) }

  describe "#archived?" do
    it "returns true if the user is archived in all given organisations" do
      expect(user_archived_status).to be_archived
    end

    it "returns false if the user is not archived in all given organisations" do
      archive1.destroy
      expect(user_archived_status).not_to be_archived
    end
  end
end
