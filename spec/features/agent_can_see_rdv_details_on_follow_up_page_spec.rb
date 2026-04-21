describe "Agents can see RDV details on the follow up page", :js do
  include_context "with all existing categories"

  let(:department) { create(:department) }
  let(:organisation) { create(:organisation, department: department, name: "Service RSA") }
  let(:agent) { create(:agent, organisations: [organisation]) }
  let!(:category_configuration) do
    create(:category_configuration, organisation:, motif_category: category_rsa_orientation)
  end
  let(:user) { create(:user, organisations: [organisation]) }
  let!(:follow_up) do
    create(:follow_up, user:, status: "rdv_pending", motif_category: category_rsa_orientation)
  end
  let(:motif) do
    create(:motif, organisation: organisation, motif_category: category_rsa_orientation, name: "RDV d'orientation")
  end
  let(:rdv) do
    create(:rdv, organisation: organisation, motif: motif, starts_at: 3.days.from_now)
  end
  let!(:participation) do
    create(
      :participation,
      follow_up:, user:, rdv:, status: "unknown",
      created_by_type: "agent", created_at: Time.zone.parse("2024-03-10 14:30")
    )
  end

  before { setup_agent_session(agent) }

  it "expands the details panel when clicking on the row" do
    visit organisation_user_follow_ups_path(organisation_id: organisation.id, user_id: user.id)

    expect(page).to have_content("Date du RDV")
    expect(page).to have_no_content("RDV pris le :")

    find("td", text: "RDV d'orientation").click

    expect(page).to have_content("RDV pris le")
    expect(page).to have_content("10/03/2024 à 14:30")
    expect(page).to have_content("Par")
    expect(page).to have_content("l'agent")
    expect(page).to have_content("Demandé par")
    expect(page).to have_content("Service RSA")
  end

  it "does not expand the details panel when clicking on the status dropdown" do
    visit organisation_user_follow_ups_path(organisation_id: organisation.id, user_id: user.id)

    expect(page).to have_content("Date du RDV")
    expect(page).to have_no_content("RDV pris le")

    click_button("RDV à venir")

    within(".dropdown-menu") do
      expect(page).to have_button("Annulé (excusé)")
    end
    expect(page).to have_no_content("RDV pris le")
  end

  context "when the user has multiple RDVs" do
    let(:older_motif) do
      create(:motif, organisation: organisation, motif_category: category_rsa_orientation,
                     name: "Premier entretien d'orientation")
    end
    let(:older_rdv) do
      create(:rdv, organisation: organisation, motif: older_motif, starts_at: 2.months.ago)
    end
    let!(:older_participation) do
      create(:participation, follow_up:, user:, rdv: older_rdv, status: "seen",
                             created_at: Time.zone.parse("2024-01-15 10:00"))
    end

    it "displays the historical RDVs under the 'Historique sur le suivi' section" do
      visit organisation_user_follow_ups_path(organisation_id: organisation.id, user_id: user.id)

      expect(page).to have_content("Historique sur le suivi")
      expect(page.text).to match(/RDV d'orientation.*Historique sur le suivi.*Premier entretien d'orientation/m)
    end
  end
end
