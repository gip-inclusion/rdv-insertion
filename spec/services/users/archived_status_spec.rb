describe Users::ArchivedStatus, type: :service do
  subject do
    described_class.call(user:, organisations:)
  end

  let(:user) { create(:user, organisations:) }
  let(:organisation1) { create(:organisation) }
  let(:organisation2) { create(:organisation) }
  let(:organisations) { [organisation1, organisation2] }
  let!(:archive1) { create(:archive, organisation: organisation1, user:) }
  let!(:archive2) { create(:archive, organisation: organisation2, user:) }

  describe "#is_archived" do
    it "returns true if the user is archived in all given organisations" do
      expect(subject.is_archived).to be true
    end

    it "returns false if the user is not archived in all given organisations" do
      archive1.destroy
      expect(subject.is_archived).to be false
    end
  end

  describe "#archived_banner_content" do
    it "returns banner content if the user is archived" do
      expect(subject.archived_banner_content[:title]).to eq("Dossier archivé")
      expect(subject.archived_banner_content[:description]).to include(
        "Ce bénéficiaire est archivé sur les organisations #{organisations.map(&:name).join(', ')}"
      )
    end
  end
end
