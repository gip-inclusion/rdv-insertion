describe "User can see invalid invitation informations", :js do
  let!(:department) { create(:department) }
  let!(:organisation1) do
    create(
      :organisation,
      department: department,
      name: "FT Paris Nord",
      phone_number: "01 23 45 67 89",
      email: "contact@FT-paris-nord.fr"
    )
  end
  let!(:organisation2) do
    create(
      :organisation,
      department: department,
      name: "FT Paris Sud",
      phone_number: "01 98 76 54 32",
      email: "contact@FT-paris-sud.fr"
    )
  end
  let!(:user) { create(:user, organisations: [organisation1, organisation2]) }
  let!(:motif_category) { create(:motif_category, short_name: "rsa_orientation") }
  let!(:invitation) do
    create(
      :invitation,
      user: user,
      format: "email",
      expires_at: 2.days.ago,
      organisations: [organisation1, organisation2]
    )
  end

  it "displays the invalid invitation message and organisation contact information" do
    visit redirect_invitations_path(uuid: invitation.uuid)

    expect(page).to have_content("Votre invitation à prendre rendez-vous a expirée")
    expect(page).to have_content("Le délai pour prendre rendez-vous avec cette invitation est maintenant dépassé")

    expect(page).to have_content("Pour planifier votre rendez-vous, nous vous invitons à contacter une des organisations suivantes")

    expect(page).to have_content("FT Paris Nord")
    expect(page).to have_content("01 23 45 67 89")
    expect(page).to have_content("contact@FT-paris-nord.fr")

    expect(page).to have_content("FT Paris Sud")
    expect(page).to have_content("01 98 76 54 32")
    expect(page).to have_content("contact@FT-paris-sud.fr")
  end
end
