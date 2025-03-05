RSpec.describe OrganisationMailer do
  describe "#notify_no_available_slots" do
    let(:organisation) { create(:organisation) }
    let(:motif_category) { create(:motif_category, name: "RSA Orientation") }
    let(:category_configuration) do
      create(:category_configuration, organisation:, email_to_notify_no_available_slots: "test@test.com")
    end
    let!(:invitation) do
      create(
        :invitation,
        organisations: [organisation],
        follow_up: create(:follow_up, motif_category:),
        user: create(:user, address_geocoding: create(:address_geocoding, post_code: "75001")),
        link: "http://rdv-solidarites-test.fr?referent_ids%5B%5D=17"
      )
    end
    let!(:agent) { create(:agent, rdv_solidarites_agent_id: 17, email: "referent@test.com") }

    it "sends the email" do
      mail = described_class.notify_no_available_slots(
        organisation:,
        invitations: [invitation],
        recipient: category_configuration.email_to_notify_no_available_slots,
        motif_category_name: motif_category.name
      )

      expect(mail.to).to eq(["test@test.com"])
      expect(ActionView::Base.full_sanitizer.sanitize(mail.body.encoded)).to(
        include("Nombre d'invitations concernées : 1")
      )
      expect(ActionView::Base.full_sanitizer.sanitize(mail.body.encoded)).to(
        include("Les codes postaux concernés sont : 75001")
      )
      expect(ActionView::Base.full_sanitizer.sanitize(mail.body.encoded)).to(
        include("Les email des référents concernés sont : referent@test.com")
      )
    end
  end

  describe "#notify_rdv_changes" do
    let(:organisation) { create(:organisation) }
    let(:category_configuration) do
      create(:category_configuration, organisation:, email_to_notify_rdv_changes: "test@test.com")
    end
    let(:follow_up) { create(:follow_up, motif_category_id: category_configuration.motif_category_id) }
    let(:agent_prescripteur) { create(:agent, first_name: "Jean", last_name: "Pierre") }
    let(:participation) { create(:participation, organisation:, follow_up:, agent_prescripteur:) }
    let!(:rdv) { create(:rdv, participations: [participation], organisation:) }

    it "sends the email" do
      mail = described_class.notify_rdv_changes(
        to: category_configuration.email_to_notify_rdv_changes,
        rdv: rdv,
        participations: [participation],
        event: "created"
      )

      expect(mail.to).to eq(["test@test.com"])
      expect(mail.body.encoded).to include("Évènement : Prise de rendez-vous")
      expect(mail.body.encoded).to include("(professionel : Jean PIERRE)")
    end
  end

  describe "#creneau_unavailable" do
    let(:organisation) { create(:organisation) }
    let(:motif_category) { create(:motif_category, name: "RSA Orientation") }
    let(:invitation) do
      create(
        :invitation,
        organisations: [organisation],
        user: create(:user, address_geocoding: create(:address_geocoding, post_code: "75001")),
        link: "http://rdv-solidarites-test.fr?referent_ids%5B%5D=17",
        follow_up: create(:follow_up, motif_category:)
      )
    end
    let(:invitation2) do
      create(
        :invitation,
        organisations: [organisation],
        user: create(:user, address_geocoding: create(:address_geocoding, post_code: "75001")),
        follow_up: create(:follow_up, motif_category:)
      )
    end
    let!(:agent) { create(:agent, rdv_solidarites_agent_id: 17, email: "referent@test.com") }
    let(:invitations_without_creneaux_by_motif_category) { { motif_category => [invitation, invitation2] } }

    it "sends the email" do
      mail = described_class.creneau_unavailable(
        organisation:,
        invitations_without_creneaux_by_motif_category:
      )

      expect(mail.to).to eq([organisation.email])
      expect(mail.body.encoded).to include("Les email des référents concernés sont : referent@test.com")
      expect(mail.body.encoded).to include("Les codes postaux concernés sont : 75001")
      expect(ActionView::Base.full_sanitizer.sanitize(mail.body.encoded)).to(
        include("Nombre d'invitations concernées : 2")
      )
    end
  end
end
