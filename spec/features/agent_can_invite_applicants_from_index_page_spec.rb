describe "Agents can invite from index page", js: true do
  let!(:agent) { create(:agent) }
  let!(:organisation) { create(:organisation, agents: [agent]) }
  let!(:applicant) do
    create(
      :applicant,
      organisations: [organisation], email: "someemail@somecompany.com", phone_number: "0607070707"
    )
  end
  let!(:motif_category) { create(:motif_category, short_name: "rsa_follow_up") }
  let!(:rdv_solidarites_token) { "123456" }
  let!(:rdv_context) { create(:rdv_context, applicant: applicant, motif_category: motif_category) }
  let!(:configuration) do
    create(
      :configuration,
      motif_category: motif_category, organisations: [organisation], invitation_formats: %w[sms email]
    )
  end
  let!(:motif) { create(:motif, motif_category: motif_category, organisation: organisation) }

  before do
    setup_agent_session(agent)
    stub_rdv_solidarites_invitation_requests
    stub_geo_api_request
  end

  context "when no invitations is sent" do
    it "can invite the applicant" do
      rdv_context.set_status
      rdv_context.save!

      visit organisation_applicants_path(organisation, motif_category_id: motif_category.id)
      expect(page).to have_field("sms_invite", checked: false, disabled: false)
      expect(page).to have_field("email_invite", checked: false, disabled: false)
      expect(page).to have_content("Non invité")

      check("email_invite")

      expect(page).to have_field("email_invite", checked: true, disabled: true)
      expect(page).to have_field("sms_invite", checked: false, disabled: false)
      expect(page).to have_content("Invitation en attente de réponse")
    end
  end

  context "when an invitation has been sent" do
    let!(:sms_invitation) do
      create(
        :invitation,
        format: "sms", applicant: applicant, rdv_context: rdv_context, sent_at: 2.days.ago,
        rdv_solidarites_token: rdv_solidarites_token
      )
    end

    it "can invite in the format where invitation has not been sent" do
      rdv_context.set_status
      rdv_context.save!

      visit organisation_applicants_path(organisation, motif_category_id: motif_category.id)
      expect(page).to have_field("sms_invite", checked: true, disabled: true)
      expect(page).to have_field("email_invite", checked: false, disabled: false)
      expect(page).to have_content("Invitation en attente de réponse")

      check("email_invite")

      expect(page).to have_field("sms_invite", checked: true, disabled: true)
      expect(page).to have_field("email_invite", checked: true, disabled: true)
      expect(page).to have_content("Invitation en attente de réponse")
    end
  end

  context "when there are rdvs" do
    let!(:rdv) { create(:rdv) }
    let!(:participation) do
      create(
        :participation,
        rdv: rdv, applicant: applicant, rdv_context: rdv_context, status: "seen", created_at: 4.days.ago
      )
    end

    context "when the applicant has been invited prior to the rdv" do
      let!(:sms_invitation) do
        create(
          :invitation,
          format: "sms", applicant: applicant, rdv_context: rdv_context, sent_at: 6.days.ago,
          rdv_solidarites_token: rdv_solidarites_token
        )
      end

      it "can invite the applicant in all format" do
        rdv_context.set_status
        rdv_context.save!

        visit organisation_applicants_path(organisation, motif_category_id: motif_category.id)
        expect(page).to have_field("sms_invite", checked: false, disabled: false)
        expect(page).to have_field("email_invite", checked: false, disabled: false)
        expect(page).to have_content("RDV honoré")

        check("email_invite")

        expect(page).to have_field("email_invite", checked: true, disabled: true)
        expect(page).to have_field("sms_invite", checked: false, disabled: false)
        expect(page).to have_content("Invitation en attente de réponse")
      end
    end

    context "when the invitation has been sent after the rdv" do
      let!(:sms_invitation) do
        create(
          :invitation,
          format: "sms", applicant: applicant, rdv_context: rdv_context, sent_at: 2.days.ago,
          rdv_solidarites_token: rdv_solidarites_token
        )
      end

      it "can invite in the format where invitation has not been sent" do
        rdv_context.set_status
        rdv_context.save!

        visit organisation_applicants_path(organisation, motif_category_id: motif_category.id)
        expect(page).to have_field("sms_invite", checked: true, disabled: true)
        expect(page).to have_field("email_invite", checked: false, disabled: false)
        expect(page).to have_content("Invitation en attente de réponse")

        check("email_invite")

        expect(page).to have_field("sms_invite", checked: true, disabled: true)
        expect(page).to have_field("email_invite", checked: true, disabled: true)
        expect(page).to have_content("Invitation en attente de réponse")
      end
    end

    context "when the rdv is pending" do
      let!(:rdv) { create(:rdv, starts_at: 2.days.from_now) }
      let!(:participation) do
        create(
          :participation,
          rdv: rdv, applicant: applicant, rdv_context: rdv_context, status: "unknown", created_at: 4.days.ago
        )
      end

      let!(:sms_invitation) do
        create(
          :invitation,
          format: "sms", applicant: applicant, rdv_context: rdv_context, sent_at: 2.days.ago,
          rdv_solidarites_token: rdv_solidarites_token
        )
      end

      it "cannot invite in any format and do not show the invitation fields" do
        rdv_context.set_status
        rdv_context.save!

        visit organisation_applicants_path(organisation, motif_category_id: motif_category.id)
        expect(page).not_to have_field("sms_invite")
        expect(page).not_to have_field("email_invite")
        expect(page).to have_content("RDV pris")
      end
    end
  end

  def stub_rdv_solidarites_invitation_requests
    stub_request(:post, "#{ENV['RDV_SOLIDARITES_URL']}/api/v1/users/#{applicant.rdv_solidarites_user_id}/invite")
      .with(headers: { "Content-Type" => "application/json" }.merge(session_hash(agent.email)))
      .to_return(body: { "invitation_token" => "123456" }.to_json)

    stub_request(:get, "#{ENV['RDV_SOLIDARITES_URL']}/api/v1/invitations/#{rdv_solidarites_token}")
      .with(headers: { "Content-Type" => "application/json" }.merge(session_hash(agent.email)))
      .to_return(status: 404)
  end

  def stub_geo_api_request
    stub_request(:get, RetrieveGeolocalisation::API_ADRESSE_URL).with(
      headers: { "Content-Type" => "application/json" },
      query: { "q" => applicant.address }
    ).to_return(body: { "features" => [] }.to_json)
  end
end
