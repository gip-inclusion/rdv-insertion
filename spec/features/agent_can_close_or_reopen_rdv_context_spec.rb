describe "Agents can close or reopen rdv_context", js: true do
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

  before do
    setup_agent_session(agent)
  end

  context "when rdv_context is not closed" do
    let!(:rdv_context) do
      create(:rdv_context, status: "not_invited", applicant: applicant, motif_category: category_orientation)
    end

    context "from department applicant page" do
      it "can close a rdv_context" do
        visit department_applicant_path(department, applicant)
        expect(page).to have_content("Clôturer \"RSA orientation\"")

        click_button("Clôturer \"RSA orientation\"")
        expect(page).to have_content("\"RSA orientation\"")
        rdv_context.reload.set_status
        rdv_context.save!

        expect(page).to have_content("Rouvrir \"RSA orientation\"")
        expect(page).to have_content("Dossier traité le")
        expect(rdv_context.status).to eq("closed")
        expect(page).to have_current_path(department_applicant_path(department, applicant))
      end
    end

    context "from organisation applicant page" do
      it "can close a rdv_context" do
        visit organisation_applicant_path(organisation, applicant)
        expect(page).to have_content("Clôturer \"RSA orientation\"")

        click_button("Clôturer \"RSA orientation\"")
        expect(page).to have_content("\"RSA orientation\"")
        rdv_context.reload.set_status
        rdv_context.save!

        expect(page).to have_content("Rouvrir \"RSA orientation\"")
        expect(page).to have_content("Dossier traité le")
        expect(rdv_context.status).to eq("closed")
        expect(page).to have_current_path(organisation_applicant_path(organisation, applicant))
      end
    end
  end

  context "when rdv_context is closed" do
    let!(:rdv_context) do
      create(:rdv_context, status: "closed", applicant: applicant, motif_category: category_orientation,
                           closed_at: Time.zone.now)
    end

    context "from department applicant page" do
      it "can reopen a rdv_context" do
        visit department_applicant_path(department, applicant)
        expect(page).to have_content("Rouvrir \"RSA orientation\"")

        click_button("Rouvrir \"RSA orientation\"")
        expect(page).to have_content("\"RSA orientation\"")
        rdv_context.reload.set_status
        rdv_context.save!

        expect(page).to have_content("Clôturer \"RSA orientation\"")
        expect(page).to have_content("Non invité")
        expect(rdv_context.status).to eq("not_invited")
        expect(rdv_context.closed_at).to eq(nil)
        expect(page).to have_current_path(department_applicant_path(department, applicant))
      end
    end

    context "from organisation applicant page" do
      it "can reopen a rdv_context" do
        visit organisation_applicant_path(organisation, applicant)
        expect(page).to have_content("Rouvrir \"RSA orientation\"")

        click_button("Rouvrir \"RSA orientation\"")
        expect(page).to have_content("\"RSA orientation\"")
        rdv_context.reload.set_status
        rdv_context.save!

        expect(page).to have_content("Clôturer \"RSA orientation\"")
        expect(page).to have_content("Non invité")
        expect(rdv_context.closed_at).to eq(nil)
        expect(page).to have_current_path(organisation_applicant_path(organisation, applicant))
      end
    end
  end
end
