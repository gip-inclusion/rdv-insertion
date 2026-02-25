describe Notification do
  describe "#display_agent_names?" do
    subject { notification.display_agent_names? }

    let!(:motif_category) { create(:motif_category) }
    let!(:organisation) { create(:organisation) }
    let!(:category_configuration) { create(:category_configuration, motif_category:, organisation:) }
    let!(:follow_up) { create(:follow_up, motif_category:) }
    let!(:participation) { create(:participation, follow_up:) }
    let!(:rdv) { create(:rdv, organisation:, participations: [participation]) }
    let!(:notification) { create(:notification, participation:) }

    context "when the motif is a follow up and agents are present" do
      before { rdv.motif.update!(follow_up: true) }

      it { is_expected.to be true }
    end

    context "when the category_configuration has rdv_with_referents and agents are present" do
      before { category_configuration.update!(rdv_with_referents: true) }

      it { is_expected.to be true }
    end

    context "when neither condition is met" do
      it { is_expected.to be false }
    end

    context "when referents_related? is true but agents are empty" do
      before do
        rdv.motif.update!(follow_up: true)
        rdv.agents = []
      end

      it { is_expected.to be false }
    end
  end
end
