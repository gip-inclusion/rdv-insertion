describe User::Geocodable, type: :concern do
  subject { user.save }

  describe "#assign_geocoding" do
    context "when the user is not persisted yet" do
      let!(:user) { build(:user, address: nil) }

      context "when an address is assigned" do
        it "calls the assign geocoding job" do
          user.address = "20 avenue de Ségur"
          expect(RetrieveAndAssignUserAddressGeocodingJob).to receive(:perform_async)
          subject
        end
      end

      context "when no address is assigned" do
        it "does not call the assign geocoding job" do
          expect(RetrieveAndAssignUserAddressGeocodingJob).not_to receive(:perform_async)
          subject
        end
      end
    end

    context "when the user is persisted" do
      let!(:user) { create(:user, address: "20 avenue de Ségur") }

      context "when the user address changes" do
        it "calls the assign geocoding job" do
          user.address = "120 boulevard de grenelle"
          expect(RetrieveAndAssignUserAddressGeocodingJob).to receive(:perform_async)
          subject
        end

        context "when the address is nullified" do
          it "calls the assign geocoding job" do
            user.address = nil
            expect(RetrieveAndAssignUserAddressGeocodingJob).to receive(:perform_async)
            subject
          end
        end
      end

      context "when the user address does not change" do
        it "does not call the assign geocoding job" do
          user.first_name = "Bill"
          expect(RetrieveAndAssignUserAddressGeocodingJob).not_to receive(:perform_async)
          subject
        end
      end
    end
  end
end
