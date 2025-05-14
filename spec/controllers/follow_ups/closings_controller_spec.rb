describe FollowUps::ClosingsController do
  let!(:agent) { create(:agent, organisations: [organisation]) }
  let!(:department) { create(:department) }
  let!(:motif_category) { create(:motif_category) }
  let!(:category_configuration) { create(:category_configuration, motif_category: motif_category) }
  let!(:organisation) do
    create(:organisation, department: department, category_configurations: [category_configuration])
  end
  let!(:user) { create(:user, department: organisation.department, organisations: [organisation]) }
  let!(:follow_up) { create(:follow_up, user: user, motif_category: motif_category) }

  before do
    sign_in(agent)
    request.env["HTTP_REFERER"] = department_user_follow_ups_url(department_id: department.id, user_id: user.id)
  end

  describe "#create" do
    before do
      allow(FollowUps::Close).to receive(:call)
        .with(follow_up: follow_up)
        .and_return(OpenStruct.new(success?: true))
    end

    let(:create_params) do
      { follow_up_id: follow_up.id, user_id: user.id, department_id: department.id }
    end

    it "calls the close follow_up service" do
      expect(FollowUps::Close).to receive(:call)
        .with(follow_up: follow_up)
      post :create, params: create_params
    end

    context "when the follow_up is closed successfully" do
      it "redirects to user follow_ups" do
        post :create, params: create_params
        expect(response).to redirect_to(department_user_follow_ups_path(department_id: department.id,
                                                                        user_id: user.id))
      end
    end

    context "when organisation level" do
      before do
        request.env["HTTP_REFERER"] =
          organisation_user_follow_ups_url(organisation_id: organisation.id, user_id: user.id)
      end

      let(:create_params) do
        { follow_up_id: follow_up.id, user_id: user.id,
          organisation_id: organisation.id }
      end

      context "when the follow_up is closed successfully" do
        it "redirects to user show at organisation level" do
          post :create, params: create_params
          expect(response).to redirect_to(organisation_user_follow_ups_path(organisation_id: organisation.id,
                                                                            user_id: user.id))
        end
      end
    end
  end

  describe "#destroy" do
    let(:destroy_params) do
      { follow_up_id: follow_up.id, user_id: user.id,
        department_id: department.id }
    end
    let!(:follow_up) do
      create(:follow_up, user: user, motif_category: motif_category,
                         status: "closed", closed_at: Time.zone.now)
    end

    it "updates the follow_up closed_at" do
      post :destroy, params: destroy_params
      expect(follow_up.reload.closed_at).to eq(nil)
    end

    context "when the follow_up is closed successfully" do
      it "redirects to user show" do
        post :destroy, params: destroy_params
        expect(response).to redirect_to(department_user_follow_ups_path(department_id: department.id,
                                                                        user_id: user.id))
      end
    end

    context "when organisation level" do
      before do
        request.env["HTTP_REFERER"] =
          organisation_user_follow_ups_url(organisation_id: organisation.id, user_id: user.id)
      end

      let(:destroy_params) do
        { follow_up_id: follow_up.id, user_id: user.id,
          organisation_id: organisation.id }
      end

      context "when the follow_up is closed successfully" do
        it "redirects to user show at organisation level" do
          post :destroy, params: destroy_params
          expect(response).to redirect_to(organisation_user_follow_ups_path(organisation_id: organisation.id,
                                                                            user_id: user.id))
        end
      end
    end
  end
end
