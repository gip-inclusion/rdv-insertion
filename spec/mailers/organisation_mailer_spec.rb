RSpec.describe OrganisationMailer do
  describe "#notify_no_available_slots" do
    let(:organisation) { create(:organisation) }
    let(:category_configuration) do
      create(:category_configuration, organisation:, email_to_notify_no_available_slots: "test@test.com")
    end
    let(:grouped_invitation_params) do
      {
        motif_category_id: category_configuration.motif_category_id,
        motif_category_name: category_configuration.motif_category.name,
        invitations_counter: 3
      }
    end

    it "sends the email" do
      mail = described_class.notify_no_available_slots(
        organisation:,
        recipient: category_configuration.email_to_notify_no_available_slots,
        grouped_invitation_params:
      )

      expect(mail.to).to eq(["test@test.com"])
      expect(ActionView::Base.full_sanitizer.sanitize(mail.body.encoded)).to include("Nombre d'invitations concernées : 3")
    end
  end

  describe "#notify_rdv_changes" do
    let(:organisation) { create(:organisation) }
    let(:category_configuration) do
      create(:category_configuration, organisation:, email_to_notify_rdv_changes: "test@test.com")
    end
    let(:follow_up) { create(:follow_up, motif_category_id: category_configuration.motif_category_id) }
    let(:participation) { create(:participation, organisation:, follow_up:) }

    it "sends the email" do
      mail = described_class.notify_rdv_changes(
        to: category_configuration.email_to_notify_rdv_changes,
        organisation: participation.organisation,
        participation: participation,
        event: "created"
      )

      expect(mail.to).to eq(["test@test.com"])
      expect(mail.body.encoded).to include("Évènement : Prise de rendez-vous")
    end
  end

  describe "#creneau_unavailable" do
    let(:organisation) { create(:organisation) }
    let(:category_configuration) { create(:category_configuration, organisation:) }
    let(:agent) { create(:agent) }
    let(:grouped_invitation_params) do
      {
        motif_category_id: category_configuration.motif_category_id,
        motif_category_name: category_configuration.motif_category.name,
        referent_ids: [agent.rdv_solidarites_agent_id],
        invitations_counter: 3
      }
    end

    it "sends the email" do
      mail = described_class.creneau_unavailable(
        organisation: organisation,
        grouped_invitation_params_by_category: [grouped_invitation_params]
      )

      expect(mail.to).to eq([organisation.email])
      expect(mail.body.encoded).to include("Les email des référents concernés sont : #{agent.email}")
    end
  end
end
