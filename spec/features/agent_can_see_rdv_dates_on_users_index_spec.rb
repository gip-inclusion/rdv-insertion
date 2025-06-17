describe "Agent can see rdv dates on users index", :js do
  let!(:department) { create(:department) }
  let!(:organisation) { create(:organisation, department:) }
  let!(:agent) { create(:agent, organisations: [organisation]) }
  let!(:user) { create(:user, organisations: [organisation]) }
  let!(:motif_category) { create(:motif_category) }
  let!(:category_configuration) do
    create(:category_configuration, organisation: organisation, motif_category: motif_category)
  end
  let!(:motif) { create(:motif, organisation:, motif_category:) }
  let!(:follow_up) { create(:follow_up, user:, motif_category:, status: "rdv_pending") }
  let!(:rdv) { create(:rdv, organisation: organisation, motif: motif, starts_at: 2.days.from_now) }
  let!(:participation) { create(:participation, follow_up:, user:, rdv:, status: "unknown") }

  before do
    setup_agent_session(agent)
  end

  context "when the user has a pending rdv" do
    context "on the all users tab" do
      it "displays the current pending rdv date" do
        visit organisation_users_path(organisation)

        within("td#follow-up-status-#{follow_up.id}") do
          expect(page).to have_content(rdv.starts_at.strftime("RDV à venir (le %d/%m/%Y)"))
        end
      end
    end

    context "on the motif category tab" do
      it "displays the current pending rdv date" do
        visit organisation_users_path(organisation, motif_category_id: motif_category.id)

        within("td#follow-up-status-#{follow_up.id}") do
          expect(page).to have_content(rdv.starts_at.strftime("RDV à venir (le %d/%m/%Y)"))
        end
      end
    end

    context "when the rdv is today but in the past" do
      let!(:rdv) do
        create(:rdv, organisation: organisation, motif: motif, starts_at: Time.zone.parse("2024-06-01 10:30"))
      end

      before do
        travel_to(Time.zone.parse("2024-06-01 12:30"))
      end

      it "displays the current pending rdv date" do
        visit organisation_users_path(organisation)

        within("td#follow-up-status-#{follow_up.id}") do
          expect(page).to have_content(rdv.starts_at.strftime("RDV à venir (le %d/%m/%Y)"))
        end
      end
    end
  end

  context "when the user has a seen rdv" do
    let!(:rdv) { create(:rdv, organisation: organisation, motif: motif, starts_at: 2.days.ago) }
    let!(:participation) { create(:participation, follow_up:, user:, rdv:, status: "seen") }
    let!(:follow_up) { create(:follow_up, user:, motif_category:, status: "rdv_seen") }

    context "on the all users tab" do
      it "displays the current seen rdv date" do
        visit organisation_users_path(organisation)

        within("td#follow-up-status-#{follow_up.id}") do
          expect(page).to have_content(rdv.starts_at.strftime("RDV honoré (le %d/%m/%Y)"))
        end
      end
    end

    context "on the motif category tab" do
      it "displays the current seen rdv date" do
        visit organisation_users_path(organisation, motif_category_id: motif_category.id)

        within("td#follow-up-status-#{follow_up.id}") do
          expect(page).to have_content(rdv.starts_at.strftime("RDV honoré (le %d/%m/%Y)"))
        end
      end
    end
  end
end
