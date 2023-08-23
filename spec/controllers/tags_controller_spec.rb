describe TagsController do
  let!(:organisation) { create(:organisation) }
  let!(:organisation2) { create(:organisation) }
  let!(:agent) do
    create(
      :agent,
      organisations: [organisation], first_name: "Bernard", last_name: "Lama", email: "bernardlama@france98.fr"
    )
  end

  before do
    sign_in(agent)
  end

  describe "#create" do
    it "affects created tag to the organisation" do
      expect do
        post :create, params: { organisation_id: organisation.id, tag: { value: "prout" } }
      end.to change(Tag, :count).by(1)
      expect(organisation.reload.tags.last.value).to eq("prout")
    end

    it "does not create the same tag twice" do
      expect do
        2.times do
          post :create, params: { organisation_id: organisation.id, tag: { value: "prout" } }
        end
      end.to change(Tag, :count).by(1)
    end
  end

  describe "#destroy" do
    before do
      organisation.tags << create(:tag)
    end

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
end
