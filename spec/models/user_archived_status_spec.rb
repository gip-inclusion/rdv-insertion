describe UserArchivedStatus do
  let!(:user_archived_status) { described_class.new(user, organisations) }
  let(:user) { create(:user, organisations:) }
  let(:organisation1) { create(:organisation) }
  let(:organisation2) { create(:organisation) }
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

  describe "#banner_content" do
    it "returns banner content if the user is archived" do
      expect(user_archived_status.banner_content[:title]).to eq("Dossier archivé")
      expect(user_archived_status.banner_content[:description]).to include(
        "Ce bénéficiaire est archivé sur les organisations #{organisations.map(&:name).join(', ')}"
      )
    end
  end
end
