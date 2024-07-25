describe Motif do
  describe "after update" do
    context "motif_category changed" do
      let(:motif) { create(:motif) }

      context "when motif has rdvs" do
        let!(:rdv) { create(:rdv, motif:) }

        it "calls AlertMotifCategoryHasChangedJob.perform_async" do
          expect(AlertMotifCategoryHasChangedJob).to receive(:perform_async).with(motif.id)

          motif.update(motif_category_id: create(:motif_category).id)
        end
      end

      context "when motif has no rdvs" do
        it "does not call AlertMotifCategoryHasChangedJob.perform_async" do
          motif = create(:motif)

          expect(AlertMotifCategoryHasChangedJob).not_to receive(:perform_async)

          motif.update(motif_category_id: create(:motif_category).id)
        end
      end
    end

    context "motif_category not changed" do
      it "does not call AlertMotifCategoryHasChangedJob.perform_async" do
        motif = create(:motif)

        expect(AlertMotifCategoryHasChangedJob).not_to receive(:perform_async)

        motif.update(name: "New name")
      end
    end
  end
end
