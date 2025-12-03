describe PurgeApiCallsJob do
  describe "#perform" do
    let!(:recent_api_call) { create(:api_call, created_at: 6.months.ago) }
    let!(:old_api_call) { create(:api_call, created_at: 13.months.ago) }

    it "deletes api calls older than 1 year" do
      expect { described_class.perform_now }.to change(ApiCall, :count).by(-1)

      expect(ApiCall.exists?(recent_api_call.id)).to be(true)
      expect(ApiCall.exists?(old_api_call.id)).to be(false)
    end
  end
end
