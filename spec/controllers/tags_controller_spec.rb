describe TagsController do
  let!(:organisation) { create(:organisation) }
  let!(:organisation2) { create(:organisation) }
  let!(:admin_agent) do
    create(
      :agent,
      admin_role_in_organisations: [organisation],
      first_name: "Bernard",
      last_name: "Lama",
      email: "bernardlama@france98.fr"
    )
  end

  before do
    sign_in(admin_agent)
  end

  describe "#create" do
    context "when agent has admin role in the organisation" do
      it "affects created tag to the organisation" do
        expect do
          post :create, params: { organisation_id: organisation.id, tag: { value: "coucou" } }
        end.to change(Tag, :count).by(1)
        expect(organisation.reload.tags.last.value).to eq("coucou")
      end

      it "does not create the same tag twice" do
        expect do
          2.times do
            post :create, params: { organisation_id: organisation.id, tag: { value: "coucou" } }
          end
        end.to change(Tag, :count).by(1)
      end
    end

    context "when agent has basic role in the organisation" do
      let!(:basic_agent) { create(:agent, basic_role_in_organisations: [organisation]) }

      before do
        sign_in(basic_agent)
      end

      it "denies access with forbidden status" do
        expect do
          post :create, params: { organisation_id: organisation.id, tag: { value: "coucou" } }
        end.not_to change(Tag, :count)

        expect(response).to redirect_to(root_url)
        expect(flash[:alert]).to eq("Votre compte ne vous permet pas d'effectuer cette action")
      end
    end

    context "when agent is admin of another organisation" do
      let!(:other_org_admin) { create(:agent, admin_role_in_organisations: [organisation2]) }

      before do
        sign_in(other_org_admin)
      end

      it "denies access to create tag in organisation they don't admin" do
        expect do
          post :create, params: { organisation_id: organisation.id, tag: { value: "coucou" } }
        end.not_to change(Tag, :count)

        expect(response).to redirect_to(root_url)
        expect(flash[:alert]).to eq("Votre compte ne vous permet pas d'effectuer cette action")
      end
    end

    context "when agent has basic role in org1 and admin role in org2" do
      let!(:mixed_agent) do
        create(:agent, basic_role_in_organisations: [organisation], admin_role_in_organisations: [organisation2])
      end

      before do
        sign_in(mixed_agent)
      end

      it "denies access to create tag in org1 where they are basic" do
        expect do
          post :create, params: { organisation_id: organisation.id, tag: { value: "coucou" } }
        end.not_to change(Tag, :count)

        expect(response).to redirect_to(root_url)
        expect(flash[:alert]).to eq("Votre compte ne vous permet pas d'effectuer cette action")
      end

      it "allows access to create tag in org2 where they are admin" do
        expect do
          post :create, params: { organisation_id: organisation2.id, tag: { value: "allowed" } }
        end.to change(Tag, :count).by(1)

        expect(response).to redirect_to(organisation_category_configurations_path(organisation2))
      end
    end
  end

  describe "#destroy" do
    before do
      organisation.tags << create(:tag)
    end

    context "when agent has admin role in the organisation" do
      it "destroys association with tag" do
        delete :destroy, params: { organisation_id: organisation.id, id: organisation.tags.first.id }
        expect(organisation.tags.reload.count).to eq(0)
        expect(Tag.count).to eq(0)
      end

      context "tag is also associated with another organisation" do
        before do
          organisation2.tags << organisation.tags.first
        end

        it "does not destroy tag" do
          delete :destroy, params: { organisation_id: organisation.id, id: organisation.tags.first.id }
          expect(organisation.tags.reload.count).to eq(0)
          expect(Tag.count).to eq(1)
        end
      end
    end

    context "when agent has basic role in the organisation" do
      let!(:basic_agent) { create(:agent, basic_role_in_organisations: [organisation]) }

      before do
        sign_in(basic_agent)
      end

      it "denies access with forbidden status" do
        tag = organisation.tags.first

        delete :destroy, params: { organisation_id: organisation.id, id: tag.id }

        expect(organisation.tags.reload.count).to eq(1)
        expect(response).to redirect_to(root_url)
        expect(flash[:alert]).to eq("Votre compte ne vous permet pas d'effectuer cette action")
      end
    end

    context "when agent is admin of another organisation" do
      let!(:other_org_admin) { create(:agent, admin_role_in_organisations: [organisation2]) }

      before do
        sign_in(other_org_admin)
      end

      it "denies access to delete tag from organisation they don't admin" do
        tag = organisation.tags.first

        delete :destroy, params: { organisation_id: organisation.id, id: tag.id }

        expect(organisation.tags.reload.count).to eq(1)
        expect(response).to redirect_to(root_url)
        expect(flash[:alert]).to eq("Votre compte ne vous permet pas d'effectuer cette action")
      end
    end

    context "when agent has basic role in org1 and admin role in org2" do
      let!(:mixed_agent) do
        create(:agent, basic_role_in_organisations: [organisation], admin_role_in_organisations: [organisation2])
      end

      before do
        sign_in(mixed_agent)
        organisation2.tags << create(:tag, value: "tag2")
      end

      it "denies access to delete tag from org1 where they are basic" do
        tag = organisation.tags.first

        delete :destroy, params: { organisation_id: organisation.id, id: tag.id }

        expect(organisation.tags.reload.count).to eq(1)
        expect(response).to redirect_to(root_url)
        expect(flash[:alert]).to eq("Votre compte ne vous permet pas d'effectuer cette action")
      end

      it "allows access to delete tag from org2 where they are admin" do
        tag2 = organisation2.tags.first

        delete :destroy, params: { organisation_id: organisation2.id, id: tag2.id }

        expect(organisation2.tags.reload.count).to eq(0)
        expect(response).to be_successful
      end
    end
  end
end
