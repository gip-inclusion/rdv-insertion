describe FollowUps::CleanUnused do
  subject { described_class.call(user:) }

  let!(:user) { create(:user, organisations: [organisation, organisation2, organisation3]) }
  let!(:department) { create(:department) }
  let!(:organisation) { create(:organisation, category_configurations: [category_configuration], department:) }
  let!(:organisation2) { create(:organisation, category_configurations: [category_configuration2], department:) }
  let!(:organisation3) { create(:organisation, category_configurations: [category_configuration3], department:) }
  let!(:category_configuration) { create(:category_configuration, motif_category: rsa_accompagnement) }
  let!(:category_configuration2) { create(:category_configuration, motif_category: rsa_accompagnement) }
  let!(:category_configuration3) { create(:category_configuration, motif_category: rsa_orientation) }
  let!(:rsa_accompagnement) { create(:motif_category) }
  let!(:rsa_orientation) { create(:motif_category, short_name: "rsa_orientation") }
  let!(:follow_up) { create(:follow_up, user: user, motif_category: rsa_accompagnement, status: "not_invited") }
  let!(:follow_up2) { create(:follow_up, user: user, motif_category: rsa_orientation, status: "not_invited") }

  describe "#call" do
    it "is a success" do
      is_a_success
    end

    it "keep follow_ups unchanged when user still belongs to organisations that handle thoses follow_ups" do
      expect { subject }.not_to change(FollowUp, :count)
    end

    it "destroy unused follow_ups when user doesnt belongs to any organisation that handle thoses follow_ups" do
      user.organisations.delete(organisation3)
      expect { subject }.to change(FollowUp, :count).by(-1)
      expect { follow_up2.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "doesnt destroy follow_ups when the user is removed from an organisation
      but he is still a member of another organisation handling this follow_up" do
      user.organisations.delete(organisation)
      expect { subject }.not_to change(FollowUp, :count)
    end

    it "doesnt destroy follow_ups when the follow_up is closed" do
      follow_up2.update_column("status", "closed")
      user.organisations.delete(organisation3)

      expect { subject }.not_to change(FollowUp, :count)
    end

    it "doesnt destroy follow_ups when the follow_up is already invited" do
      follow_up2.update_column("status", "invitation_pending")
      user.organisations.delete(organisation3)

      expect { subject }.not_to change(FollowUp, :count)
    end
  end
end
