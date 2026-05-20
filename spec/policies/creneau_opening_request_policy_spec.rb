describe CreneauOpeningRequestPolicy, type: :policy do
  subject { described_class }

  let!(:agent) { create(:agent) }
  let!(:other_agent) { create(:agent) }

  describe "#create?" do
    context "when the agent owns the user_list_upload" do
      let!(:user_list_upload) { create(:user_list_upload, agent: agent) }
      let!(:creneau_opening_request) { create(:creneau_opening_request, user_list_upload: user_list_upload) }

      permissions(:create?) { it { is_expected.to permit(agent, creneau_opening_request) } }
    end

    context "when the agent does not own the user_list_upload" do
      let!(:user_list_upload) { create(:user_list_upload, agent: other_agent) }
      let!(:creneau_opening_request) { create(:creneau_opening_request, user_list_upload: user_list_upload) }

      permissions(:create?) { it { is_expected.not_to permit(agent, creneau_opening_request) } }
    end
  end
end
