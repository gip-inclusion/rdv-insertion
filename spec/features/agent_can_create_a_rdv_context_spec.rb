describe "Agents can create a rdv_context", js: true do
  let!(:department) { create(:department) }
  let!(:organisation) { create(:organisation, department: department) }
  let!(:agent) { create(:agent, organisations: [organisation]) }
  let!(:category_orientation) do
    create(:motif_category, short_name: "rsa_orientation", name: "RSA orientation")
  end
  let!(:configuration) { create(:configuration, organisation: organisation, motif_category: category_orientation) }
  let!(:applicant) do
    create(:applicant, organisations: [organisation])
  end
  let!(:rdv_context_count_before) { RdvContext.count }

  before do
    setup_agent_session(agent)
  end

  context "from applicants index page" do
    context "at department level" do
      it "can create a rdv_context" do
        visit department_applicants_path(department)
        expect(page).to have_content("Ajouter")

        click_button("Ajouter")

        expect(page).to have_content("Non invité")
        expect(RdvContext.count).to eq(rdv_context_count_before + 1)
        expect(RdvContext.last.status).to eq("not_invited")
        expect(RdvContext.last.motif_category).to eq(category_orientation)
        expect(RdvContext.last.applicant).to eq(applicant)
        expect(page).to have_current_path(department_applicants_path(department))
      end
    end

    context "at organisation level" do
      it "can create a rdv_context" do
        visit organisation_applicants_path(organisation)
        expect(page).to have_content("Ajouter")

        click_button("Ajouter")

        expect(page).to have_content("Non invité")
        expect(RdvContext.count).to eq(rdv_context_count_before + 1)
        expect(RdvContext.last.status).to eq("not_invited")
        expect(RdvContext.last.motif_category).to eq(category_orientation)
        expect(RdvContext.last.applicant).to eq(applicant)
        expect(page).to have_current_path(organisation_applicants_path(organisation))
      end
    end
  end

  context "from applicant show page" do
    context "at department level" do
      it "can create a rdv_context" do
        visit department_applicant_path(department, applicant)
        expect(page).to have_content("Ouvrir un suivi")

        click_button("Ouvrir un suivi")

        expect(page).to have_content("Non invité")
        expect(RdvContext.count).to eq(rdv_context_count_before + 1)
        expect(RdvContext.last.status).to eq("not_invited")
        expect(RdvContext.last.motif_category).to eq(category_orientation)
        expect(RdvContext.last.applicant).to eq(applicant)
        expect(page).to have_current_path(department_applicant_path(department, applicant))
      end
    end

    context "at organisation level" do
      it "can create a rdv_context" do
        visit organisation_applicant_path(organisation, applicant)
        expect(page).to have_content("Ouvrir un suivi")

        click_button("Ouvrir un suivi")

        expect(page).to have_content("Non invité")
        expect(RdvContext.count).to eq(rdv_context_count_before + 1)
        expect(RdvContext.last.status).to eq("not_invited")
        expect(RdvContext.last.motif_category).to eq(category_orientation)
        expect(RdvContext.last.applicant).to eq(applicant)
        expect(page).to have_current_path(organisation_applicant_path(organisation, applicant))
      end
    end
  end
end
