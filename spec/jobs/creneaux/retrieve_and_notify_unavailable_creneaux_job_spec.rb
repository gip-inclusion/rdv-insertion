describe Creneaux::RetrieveAndNotifyUnavailableCreneauxJob do
  subject do
    described_class.new.perform(organisation_id)
  end

  let!(:department) { create(:department, name: "Aveyron") }
  let!(:organisation) do
    create(
      :organisation,
      email:, department:, name: "CD Aveyron",
      category_configurations: [category_configuration_rsa_orientation, category_configuration_rsa_accompagnement]
    )
  end
  let!(:organisation_id) { organisation.id }
  let(:email) { "someemail@example.com" }
  let(:category_configuration_rsa_orientation) do
    create(
      :category_configuration,
      email_to_notify_no_available_slots: email,
      motif_category: motif_category_rsa_orientation
    )
  end

  let(:category_configuration_rsa_accompagnement) do
    create(
      :category_configuration,
      email_to_notify_no_available_slots: nil,
      motif_category: motif_category_rsa_accompagnement
    )
  end

  let!(:motif_category_rsa_orientation) { create(:motif_category, name: "RSA Orientation") }
  let!(:motif_category_rsa_accompagnement) { create(:motif_category, name: "RSA Accompagnement") }

  let!(:invitation_rsa_orientation1) do
    create(
      :invitation,
      organisations: [organisation],
      user: create(:user, address_geocoding: create(:address_geocoding, post_code: "75001")),
      link: "http://rdv-solidarites-test.fr?referent_ids%5B%5D=1",
      follow_up: create(:follow_up, motif_category: motif_category_rsa_orientation)
    )
  end
  let!(:referent_rsa_orientation1) { create(:agent, rdv_solidarites_agent_id: 1, email: "referent1@example.com") }
  let!(:invitation_rsa_orientation2) do
    create(
      :invitation,
      organisations: [organisation],
      user: create(:user, address_geocoding: create(:address_geocoding, post_code: "75002")),
      link: "http://rdv-solidarites-test.fr?referent_ids%5B%5D=1",
      follow_up: create(:follow_up, motif_category: motif_category_rsa_orientation)
    )
  end

  let!(:invitation_rsa_accompagnement) do
    create(
      :invitation,
      organisations: [organisation],
      follow_up: create(:follow_up, motif_category: motif_category_rsa_accompagnement)
    )
  end

  before do
    allow(Invitations::AggregateInvitationWithoutCreneaux).to receive(:call)
      .and_return(
        OpenStruct.new(
          success?: true,
          invitations_without_creneaux: [
            invitation_rsa_orientation1,
            invitation_rsa_orientation2,
            invitation_rsa_accompagnement
          ]
        )
      )
    allow(OrganisationMailer).to receive_message_chain(:creneau_unavailable, :deliver_now)
    allow(OrganisationMailer).to receive_message_chain(:notify_no_available_slots, :deliver_now)
  end

  it "send the email" do
    expect(OrganisationMailer).to receive(:creneau_unavailable)
      .with(
        organisation: organisation,
        invitations_without_creneaux_by_motif_category: {
          motif_category_rsa_orientation => [
            invitation_rsa_orientation1,
            invitation_rsa_orientation2
          ],
          motif_category_rsa_accompagnement => [invitation_rsa_accompagnement]
        }
      )
    subject
  end

  it "sends the email to notify available slots" do
    expect(OrganisationMailer).to receive(:notify_no_available_slots)
      .with(
        organisation: organisation,
        invitations: [
          invitation_rsa_orientation1,
          invitation_rsa_orientation2
        ],
        motif_category_name: motif_category_rsa_orientation.name,
        recipient: email
      )
    subject
  end

  it "send the message to slack" do
    expect(SlackClient).to receive(:send_to_notif_channel)
      .with(
        "Créneaux indisponibles pour l'organisation CD Aveyron (Département: Aveyron)\n" \
        " Motif : RSA Orientation\n" \
        " Nombre d'invitations concernées : 2\n" \
        " Codes postaux : 75001, 75002\n" \
        " Référents (rdvsp_ids) : 1\n" \
      )
    expect(SlackClient).to receive(:send_to_notif_channel)
      .with(
        "Créneaux indisponibles pour l'organisation CD Aveyron" \
        " (Département: Aveyron)\n" \
        " Motif : RSA Accompagnement\n" \
        " Nombre d'invitations concernées : 1\n" \
      )
    subject
  end

  it "stores the invitations count in db" do
    expect { subject }.to change(BlockedInvitationsCounter, :count).by(1)
    expect(BlockedInvitationsCounter.last.number_of_invitations_affected).to eq(3)
    expect(BlockedInvitationsCounter.last.organisation).to eq(organisation)
  end

  it "stores the blocked users in db" do
    expect { subject }.to change(BlockedUser, :count).by(3)
    expect(BlockedUser.pluck(:user_id)).to contain_exactly(
      invitation_rsa_orientation1.user_id,
      invitation_rsa_orientation2.user_id,
      invitation_rsa_accompagnement.user_id
    )
  end

  context "when a user is already counted" do
    context "when it is less than 30 days ago" do
      before do
        create(:blocked_user, user: invitation_rsa_orientation1.user, created_at: 29.days.ago)
      end

      it "does not count the user again" do
        expect { subject }.to change(BlockedUser, :count).by(2)
      end
    end

    context "when it is more than 30 days ago" do
      before do
        create(:blocked_user, user: invitation_rsa_orientation1.user, created_at: 31.days.ago)
      end

      it "counts the user again" do
        expect { subject }.to change(BlockedUser, :count).by(3)
      end
    end
  end
end
