describe "Agents can invite user from user follow up page", :js do
  let!(:department) { create(:department) }
  let!(:agent) { create(:agent) }
  let!(:organisation) { create(:organisation, department: department, agents: [agent]) }
  let!(:user) do
    create(
      :user,
      organisations: [organisation], email: "someemail@somecompany.com", phone_number: "0607070707"
    )
  end
  let!(:motif_category) { create(:motif_category, short_name: "rsa_follow_up") }
  let!(:rdv_solidarites_token) { "123456" }
  let!(:follow_up) { create(:follow_up, user: user, motif_category: motif_category) }
  let!(:category_configuration) do
    create(
      :category_configuration,
      motif_category: motif_category, organisation: organisation, invitation_formats: %w[sms email postal]
    )
  end
  let!(:motif) { create(:motif, motif_category: motif_category, organisation: organisation) }

  before do
    setup_agent_session(agent)
    stub_rdv_solidarites_invitation_requests(user.rdv_solidarites_user_id, rdv_solidarites_token)
    stub_geo_api_request(user.address)
    stub_brevo
    stub_creneau_availability(true)
    follow_up.set_status
    follow_up.save
    stub_request(:post, "#{ENV['PDF_GENERATOR_URL']}/generate")
      .to_return(status: 200, body: Base64.encode64("mock pdf content"))
  end

  shared_examples "agent can invite user" do
    it "can invite the user by email" do
      invite_user("email")
      expect_successful_invitation
    end

    it "can invite the user by sms" do
      invite_user("sms")
      expect_successful_invitation
    end

    it "can invite the user by pdf" do
      find("[data-action='click->invitation-button#generatePostalInvitation']").click
      expect_successful_invitation
    end

    it "gets an error message when the invitation fails (no creneau)" do
      stub_creneau_availability(false)
      invite_user("email")
      expect_invitation_failure_message
    end

    context "when pdf generation fails" do
      before do
        stub_request(:post, "#{ENV['PDF_GENERATOR_URL']}/generate")
          .to_return(status: 500, body: "Erreur du service de génération de PDF")
        allow(Sentry).to receive(:capture_message)
      end

      it "displays an error message and notify sentry" do
        find("[data-action='click->invitation-button#generatePostalInvitation']").click
        expect(page).to have_content(
          "Une erreur est survenue lors de la génération du PDF." \
          " L'équipe a été notifiée de l'erreur et tente de la résoudre."
        )
        expect(Sentry).to have_received(:capture_message).with(
          "PDF generation failed",
          extra: { status: 500, body: "Erreur du service de génération de PDF",
                   invitation_id: Invitation.last.id }
        )
      end
    end
  end

  context "when agent is at department level" do
    before { visit department_user_follow_ups_path(department_id: department.id, user_id: user.id) }

    include_examples "agent can invite user"
  end

  context "when agent is at organisation level" do
    before { visit organisation_user_follow_ups_path(organisation_id: organisation.id, user_id: user.id) }

    include_examples "agent can invite user"
  end

  def invite_user(format)
    form = find_invitation_form(format)
    expect(form).not_to be_nil
    form.find("button", text: "Inviter").click
  end

  def find_invitation_form(format)
    all('form[data-controller="invitation-button"]').find do |f|
      f.find("input#invitation_format", visible: false).value == format
    end
  end

  def expect_successful_invitation
    expect(page).to have_content("Réinviter")
    expect(user.reload.invitations.count).to eq(1)
  end

  def expect_invitation_failure_message
    expect(page).to have_content(
      "Il n'y a plus de créneaux disponibles pour inviter cet usager.\n" \
      "Nous vous invitons à créer de nouvelles plages d'ouverture ou augmenter le délai de prise de rdv depuis " \
      "RDV-Solidarités pour pouvoir à nouveau envoyer des invitations.\nPlus d'informations sur notre guide"
    )
  end

  def stub_creneau_availability(available)
    stub_request(
      :get,
      /#{Regexp.quote(ENV['RDV_SOLIDARITES_URL'])}\/api\/rdvinsertion\/invitations\/creneau_availability.*/
    ).to_return(status: 200, body: { "creneau_availability" => available }.to_json, headers: {})
  end
end
