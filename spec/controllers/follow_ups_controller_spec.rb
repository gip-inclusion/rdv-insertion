describe FollowUpsController do
  let!(:department) { create(:department) }
  let!(:organisation) { create(:organisation, department: department) }
  let(:user) { create(:user, organisations: [organisation]) }
  let!(:category_orientation) do
    create(:motif_category, short_name: "rsa_orientation", name: "RSA orientation")
  end
  let!(:category_configuration) do
    create(:category_configuration, motif_category: category_orientation, organisation: organisation)
  end
  let(:agent) { create(:agent, organisations: [organisation]) }
  let(:follow_up_params) do
    {
      follow_up: { user_id: user.id, motif_category_id: category_orientation.id },
      category_configuration_id: category_configuration.id,
      organisation_id: organisation.id
    }
  end
  let!(:follow_up_count_before) { FollowUp.count }

  describe "#create" do
    before do
      sign_in(agent)
      request.env["HTTP_REFERER"] = organisation_user_follow_ups_url(organisation_id: organisation.id, user_id: user.id)
    end

    it "creates a new follow_up" do
      post :create, params: follow_up_params
      expect(FollowUp.count).to eq(follow_up_count_before + 1)
      expect(FollowUp.last.user).to eq(user)
      expect(FollowUp.last.motif_category).to eq(category_orientation)
    end

    context "when not authorized" do
      let!(:another_organisation) { create(:organisation) }
      let(:user) { create(:user, organisations: [another_organisation]) }

      it "is forbidden" do
        post :create, params: follow_up_params.merge(format: "turbo_stream")
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "when te creation fails" do
      let!(:follow_up) { create(:follow_up, motif_category: category_orientation, user: user) }

      it "opens an error modal" do
        post :create, params: follow_up_params

        expect(response.media_type).to eq Mime[:turbo_stream]
        expect(response.body).to match(/replace/)
        expect(response.body).to match(/remote_modal/)
      end
    end

    context "when request comes from user show page" do
      it "redirects to the user show page" do
        post :create, params: follow_up_params, format: :html

        expect(response).to redirect_to(
          organisation_user_follow_ups_path(organisation_id: organisation.id, user_id: user.id)
        )
      end

      context "when department level" do
        before do
          request.env["HTTP_REFERER"] = department_user_follow_ups_path(department_id: department.id, user_id: user.id)
        end

        let(:follow_up_params) do
          {
            follow_up: { user_id: user.id, motif_category_id: category_orientation.id },
            category_configuration_id: category_configuration.id,
            department_id: department.id
          }
        end

        it "redirects to the right path" do
          post :create, params: follow_up_params, format: :html

          expect(response).to redirect_to(
            department_user_follow_ups_path(department_id: department.id, user_id: user.id)
          )
        end
      end
    end

    context "when the request comes from the users index page" do
      before do
        request.env["HTTP_REFERER"] = organisation_users_url(organisation_id: organisation.id)
      end

      it "replace the create follow_up button" do
        post :create, params: follow_up_params, format: :turbo_stream

        expect(response).to redirect_to(organisation_users_url(organisation_id: organisation.id))
      end
    end
  end
end
