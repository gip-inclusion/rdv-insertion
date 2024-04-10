describe RdvContexts::CleanUnusedRdvContexts do
  subject { described_class.call(user:) }

  let!(:user) { create(:user, organisations: [organisation, organisation2, organisation3]) }
  let!(:organisation) { create(:organisation, configurations: [configuration]) }
  let!(:organisation2) { create(:organisation, configurations: [configuration2]) }
  let!(:organisation3) { create(:organisation, configurations: [configuration3]) }
  let!(:configuration) { create(:configuration, motif_category: rsa_accompagnement) }
  let!(:configuration2) { create(:configuration, motif_category: rsa_accompagnement) }
  let!(:configuration3) { create(:configuration, motif_category: rsa_orientation) }
  let!(:rsa_accompagnement) { create(:motif_category) }
  let!(:rsa_orientation) { create(:motif_category, short_name: "rsa_orientation") }
  let!(:rdv_context) { create(:rdv_context, user: user, motif_category: rsa_accompagnement) }
  let!(:rdv_context2) { create(:rdv_context, user: user, motif_category: rsa_orientation) }

  describe "#call" do
    it "is a success" do
      is_a_success
    end

    it "keep rdv_contexts unchanged when user still belongs to organisations that handle thoses rdv_contexts" do
      expect { subject }.not_to change(RdvContext, :count)
    end

    it "destroy unused rdv_contexts when user doesnt belongs to any organisation that handle thoses rdv_contexts" do
      user.organisations.delete(organisation3)
      expect { subject }.to change(RdvContext, :count).by(-1)
      expect { rdv_context2.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "doesnt destroy rdv_contexts when the user is removed from an organisation
      but he is still a member of another organisation handling this rdv_context" do
      user.organisations.delete(organisation)
      expect { subject }.not_to change(RdvContext, :count)
    end

    it "doesnt destroy rdv_contexts when the rdv_context is closed" do
      rdv_context2.update_column("status", "closed")
      user.organisations.delete(organisation3)

      expect { subject }.not_to change(RdvContext, :count)
    end

    it "doesnt destroy rdv_contexts when the rdv_context is already invited" do
      rdv_context2.update_column("status", "invitation_pending")
      user.organisations.delete(organisation3)

      expect { subject }.not_to change(RdvContext, :count)
    end
  end
end
