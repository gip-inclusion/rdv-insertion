describe RdvContextsController do
  let!(:department) { create(:department) }
  let!(:organisation) { create(:organisation, department: department) }
  let(:user) { create(:user, organisations: [organisation]) }
  let!(:category_orientation) do
    create(:motif_category, short_name: "rsa_orientation", name: "RSA orientation")
  end
  let!(:configuration) do
    create(:configuration, motif_category: category_orientation, organisation: organisation)
  end
  let(:agent) { create(:agent, organisations: [organisation]) }
  let(:rdv_context_params) do
    {
      rdv_context: { user_id: user.id, motif_category_id: category_orientation.id },
      configuration_id: configuration.id,
      organisation_id: organisation.id
    }
  end
  let!(:rdv_context_count_before) { RdvContext.count }
  let!(:rdv_context) { create(:rdv_context, motif_category: category_orientation, user: user) }

  describe "#create" do
    before do
      sign_in(agent)
      allow(RdvContexts::FindOrCreate).to receive(:call)
        .with(user: user, motif_category: category_orientation)
        .and_return(OpenStruct.new(success?: true, rdv_context: rdv_context))
    end

    it "creates a new rdv_context" do
      expect(RdvContexts::FindOrCreate).to receive(:call)
        .with(user: user, motif_category: category_orientation)

      post :create, params: rdv_context_params
    end

    context "when te creation fails" do
      before do
        allow(RdvContexts::FindOrCreate).to receive(:call)
          .with(user: user, motif_category: category_orientation)
          .and_return(OpenStruct.new(success?: false, errors: ["some error"]))
      end

      it "opens an error modal" do
        post :create, params: rdv_context_params

        expect(response.media_type).to eq Mime[:turbo_stream]
        expect(response.body).to match(/replace/)
        expect(response.body).to match(/remote_modal/)
      end
    end

    context "when html request" do
      it "redirects to the user show page with the right anchor" do
        post :create, params: rdv_context_params, format: :html

        expect(response).to redirect_to(
          organisation_user_rdv_contexts_path(organisation_id: organisation.id, user_id: user.id,
                                              anchor: "rdv_context_#{rdv_context.id}")
        )
      end

      context "when department level" do
        let(:rdv_context_params) do
          {
            rdv_context: { user_id: user.id, motif_category_id: category_orientation.id },
            configuration_id: configuration.id,
            department_id: department.id
          }
        end

        it "redirects to the right path" do
          post :create, params: rdv_context_params, format: :html

          expect(response).to redirect_to(
            department_user_rdv_contexts_path(department_id: department.id, user_id: user.id,
                                              anchor: "rdv_context_#{rdv_context.id}")
          )
        end
      end
    end

    context "when turbo request" do
      it "replace the create rdv_context button" do
        post :create, params: rdv_context_params, format: :turbo_stream

        expect(response.media_type).to eq Mime[:turbo_stream]
        expect(response.body).to match(/replace/)
        expect(response.body).to match(/target="user_#{user.id}_motif_category_#{category_orientation.id}"/)
      end
    end
  end
end
