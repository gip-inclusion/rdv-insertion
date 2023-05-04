describe "Agents can convene applicant to rdv", js: true do
  let!(:agent) { create(:agent, organisations: [organisation]) }
  let!(:department) { create(:department) }
  let!(:organisation) do
    create(
      :organisation,
      department: department,
      # needed for the organisation applicants page
      rdv_solidarites_organisation_id: rdv_solidarites_organisation_id
    )
  end
  let!(:rdv_solidarites_organisation_id) { 444 }
  let!(:configuration) do
    create(
      :configuration,
      organisation: organisation,
      motif_category: motif_category,
      convene_applicant: true,
      number_of_days_before_action_required: 4
    )
  end
  let!(:motif_category) { create(:motif_category) }

  let!(:applicant) do
    create(
      :applicant,
      organisations: [organisation],
      rdv_solidarites_user_id: rdv_solidarites_user_id
    )
  end
  let!(:rdv_solidarites_user_id) { 555 }

  let!(:rdv_context) do
    create(:rdv_context, status: "invitation_pending", applicant: applicant, motif_category: motif_category)
  end
  let!(:invitation) { create(:invitation, rdv_context: rdv_context, sent_at: 5.days.ago) }

  let!(:motif) do
    create(
      :motif,
      name: "Convocation au rdv",
      organisation: organisation,
      motif_category: motif_category,
      rdv_solidarites_motif_id: rdv_solidarites_motif_id,
      rdv_solidarites_service_id: rdv_solidarites_service_id
    )
  end

  let!(:expected_link) do
    params = {
      user_ids: [rdv_solidarites_user_id],
      motif_id: rdv_solidarites_motif_id,
      service_id: rdv_solidarites_service_id,
      commit: "Afficher les créneaux"
    }
    "http://www.rdv-solidarites-test.localhost/admin/organisations/#{rdv_solidarites_organisation_id}/" \
      "agent_searches?#{params.to_query}"
  end

  let!(:rdv_solidarites_motif_id) { 777 }
  let!(:rdv_solidarites_service_id) { 888 }

  before do
    setup_agent_session(agent)
  end

  describe "from #index" do
    it "shows a link to convene the applicant" do
      visit organisation_applicants_path(organisation)
      expect(page).to have_content("📅 Convoquer")
      expect(page).not_to have_css("div[data-action='mouseover->tooltip#disabledConvocationButton']")
      expect(page).to have_link("📅 Convoquer", href: expected_link)
    end

    context "when there is no convocation motif" do
      before { motif.update! name: "regular motif" }

      it "shows a disabled button to convene the applicant" do
        visit organisation_applicants_path(organisation)
        expect(page).to have_content("📅 Convoquer")
        expect(page).not_to have_link("📅 Convoquer")
        expect(page).to have_css("div[data-action='mouseover->tooltip#disabledConvocationButton']")
      end
    end

    context "when the time to accept invitation has not exceeded" do
      let!(:invitation) { create(:invitation, rdv_context: rdv_context, sent_at: 3.days.ago) }

      it "does not show a convocation button" do
        visit organisation_applicants_path(organisation)
        expect(page).not_to have_content("📅 Convoquer")
      end
    end

    context "when there is a pending rdv" do
      let!(:participation) do
        create(:participation, rdv_context: rdv_context, applicant: applicant, created_at: 1.day.ago)
      end

      it "does not show a convocation button" do
        rdv_context.set_status
        rdv_context.save!
        visit organisation_applicants_path(organisation)
        expect(page).not_to have_content("📅 Convoquer")
      end
    end

    context "when the configuration is not set to convene applicants" do
      before { configuration.update! convene_applicant: false }

      it "does not show a convocation button" do
        visit organisation_applicants_path(organisation)
        expect(page).not_to have_content("📅 Convoquer")
      end
    end

    context "when the motif is deleted" do
      before { motif.update! deleted_at: 2.days.ago }

      it "shows a disabled button to convene the applicant" do
        visit organisation_applicants_path(organisation)
        expect(page).to have_content("📅 Convoquer")
        expect(page).not_to have_link("📅 Convoquer")
        expect(page).to have_css("div[data-action='mouseover->tooltip#disabledConvocationButton']")
      end
    end

    context "from department level" do
      it "adds a link to convene the applicant" do
        visit department_applicants_path(department)
        expect(page).to have_content("📅 Convoquer")
        expect(page).not_to have_css("div[data-action='mouseover->tooltip#disabledConvocationButton']")
        expect(page).to have_link("📅 Convoquer", href: expected_link)
      end

      context "when the applicant belongs to an org without convocation motifs configured" do
        let!(:other_organisation) do
          create(:organisation, department: department, agents: [agent], configurations: [configuration])
        end
        let!(:applicant) do
          create(
            :applicant,
            organisations: [other_organisation],
            rdv_solidarites_user_id: rdv_solidarites_user_id
          )
        end

        it "adds a disabled button to convene the applicant" do
          visit department_applicants_path(department)
          expect(page).to have_content("📅 Convoquer")
          expect(page).not_to have_link("📅 Convoquer")
          expect(page).to have_css("div[data-action='mouseover->tooltip#disabledConvocationButton']")
        end
      end
    end
  end

  describe "from #show" do
    let!(:other_motif_category) { create(:motif_category) }
    let!(:other_configuration) do
      create(
        :configuration,
        motif_category: other_motif_category,
        convene_applicant: true,
        number_of_days_before_action_required: 7,
        organisation: organisation
      )
    end
    let!(:other_rdv_context) do
      create(:rdv_context, status: "invitation_pending", applicant: applicant, motif_category: other_motif_category)
    end
    let!(:other_invitation) { create(:invitation, rdv_context: other_rdv_context, sent_at: 8.days.ago) }

    let!(:other_motif) do
      create(
        :motif,
        name: "Convocation au rdv",
        organisation: organisation,
        motif_category: other_motif_category,
        rdv_solidarites_motif_id: other_rdv_solidarites_motif_id,
        rdv_solidarites_service_id: other_rdv_solidarites_service_id
      )
    end

    let!(:other_rdv_solidarites_motif_id) { 213 }
    let!(:other_rdv_solidarites_service_id) { 33 }

    let!(:other_expected_link) do
      params = {
        user_ids: [rdv_solidarites_user_id],
        motif_id: other_rdv_solidarites_motif_id,
        service_id: other_rdv_solidarites_service_id,
        commit: "Afficher les créneaux"
      }
      "http://www.rdv-solidarites-test.localhost/admin/organisations/#{rdv_solidarites_organisation_id}/" \
        "agent_searches?#{params.to_query}"
    end

    it "shows two links to convene the applicant" do
      visit organisation_applicant_path(organisation, applicant)
      expect(page).to have_content("📅 Convoquer").twice
      expect(page).not_to have_css("div[data-action='mouseover->tooltip#disabledConvocationButton']")
      expect(page).to have_link("📅 Convoquer", href: expected_link)
      expect(page).to have_link("📅 Convoquer", href: other_expected_link)
    end

    context "when there is no convocation motif in one category" do
      before { other_motif.update! name: "regular" }

      it "shows one link and one disabled button to convene the applicant" do
        visit organisation_applicant_path(organisation, applicant)
        expect(page).to have_content("📅 Convoquer").twice
        expect(page).to have_css("div[data-action='mouseover->tooltip#disabledConvocationButton']").once
        expect(page).to have_link("📅 Convoquer", href: expected_link)
        expect(page).not_to have_link("📅 Convoquer", href: other_expected_link)
      end
    end

    context "when the invitation did not time out in one category" do
      let!(:other_invitation) { create(:invitation, rdv_context: other_rdv_context, sent_at: 5.days.ago) }

      it "shows one link to convene the applicant" do
        visit organisation_applicant_path(organisation, applicant)
        expect(page).to have_content("📅 Convoquer").once
        expect(page).to have_link("📅 Convoquer", href: expected_link)
      end
    end

    context "when one configuration is not set to convene applicants" do
      before { configuration.update! convene_applicant: false }

      it "shows only one convocation button" do
        visit organisation_applicants_path(organisation)
        expect(page).to have_content("📅 Convoquer").once
      end
    end

    context "when the applicant is not invited" do
      let!(:invitation) { nil }
      let!(:other_invitation) { nil }

      it "does not show a convocation button" do
        [rdv_context, other_rdv_context].each(&:set_status)
        [rdv_context, other_rdv_context].each(&:save!)
        visit organisation_applicants_path(organisation)
        expect(page).not_to have_content("📅 Convoquer")
      end
    end

    context "on department level" do
      let!(:other_organisation) do
        create(
          :organisation,
          applicants: [applicant],
          department: department, agents: [agent], configurations: [other_configuration],
          rdv_solidarites_organisation_id: 393
        )
      end
      let!(:other_motif) do
        create(
          :motif,
          name: "Convocation au rdv",
          organisation: other_organisation,
          motif_category: other_motif_category,
          rdv_solidarites_motif_id: other_rdv_solidarites_motif_id,
          rdv_solidarites_service_id: other_rdv_solidarites_service_id
        )
      end

      let!(:other_expected_link) do
        params = {
          user_ids: [rdv_solidarites_user_id],
          motif_id: other_rdv_solidarites_motif_id,
          service_id: other_rdv_solidarites_service_id,
          commit: "Afficher les créneaux"
        }
        "http://www.rdv-solidarites-test.localhost/admin/organisations/393/" \
          "agent_searches?#{params.to_query}"
      end

      it "shows two links to convene the applicant" do
        visit department_applicant_path(department, applicant)
        expect(page).to have_content("📅 Convoquer").twice
        expect(page).not_to have_css("div[data-action='mouseover->tooltip#disabledConvocationButton']")
        expect(page).to have_link("📅 Convoquer", href: expected_link)
        expect(page).to have_link("📅 Convoquer", href: other_expected_link)
      end
    end
  end
end
