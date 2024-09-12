describe Motif do
  describe "after update" do
    context "motif_category changed" do
      let(:motif) { create(:motif) }

      context "when motif has rdvs" do
        let!(:rdv) { create(:rdv, motif:) }

        it "calls AlertMotifCategoryHasChangedJob.perform_later" do
          expect(AlertMotifCategoryHasChangedJob).to receive(:perform_later).with(motif.id)

          motif.update(motif_category_id: create(:motif_category).id)
        end

        context "when motif_category_id was nil" do
          let(:motif) { create(:motif, motif_category_id: nil) }

          it "does not call AlertMotifCategoryHasChangedJob.perform_later" do
            expect(AlertMotifCategoryHasChangedJob).not_to receive(:perform_later)

            motif.update(motif_category_id: create(:motif_category).id)
          end
        end
      end

      context "when motif has no rdvs" do
        it "does not call AlertMotifCategoryHasChangedJob.perform_later" do
          motif = create(:motif)

          expect(AlertMotifCategoryHasChangedJob).not_to receive(:perform_later)

          motif.update(motif_category_id: create(:motif_category).id)
        end
      end
    end

    context "motif_category not changed" do
      it "does not call AlertMotifCategoryHasChangedJob.perform_later" do
        motif = create(:motif)

        expect(AlertMotifCategoryHasChangedJob).not_to receive(:perform_later)

        motif.update(name: "New name")
      end
    end
  end
end
