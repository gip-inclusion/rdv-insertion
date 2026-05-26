describe CreneauOpeningRequestMailer do
  subject(:mail) { described_class.request_more_creneaux(creneau_opening_request: creneau_opening_request) }

  let!(:organisation) { create(:organisation, rdv_solidarites_organisation_id: 42) }
  let!(:motif_category) { create(:motif_category, name: "RSA Orientation") }
  let!(:category_configuration) do
    create(:category_configuration, organisation: organisation, motif_category: motif_category)
  end
  let!(:sender_agent) { create(:agent, first_name: "Maria", last_name: "Dupuis") }
  let!(:recipient_agent) { create(:agent, first_name: "Jean", last_name: "Martin", email: "jean.martin@example.fr") }
  let!(:user_list_upload) do
    create(:user_list_upload, structure: organisation, category_configuration: category_configuration,
                              agent: sender_agent)
  end
  let!(:creneau_opening_request) do
    create(:creneau_opening_request,
           user_list_upload: user_list_upload,
           recipient_agent: recipient_agent,
           users_to_invite_count: 28,
           available_creneaux_count: 26)
  end

  it "addresses the recipient agent" do
    expect(mail.to).to eq(["jean.martin@example.fr"])
  end

  it "sets the subject with the motif category name" do
    expect(mail.subject).to eq(
      "[Demande de créneaux] - Besoin de nouveaux créneaux sur la catégorie RSA Orientation"
    )
  end

  it "sets the reply-to to the team mailbox" do
    expect(mail.reply_to).to eq(["rdv-insertion@inclusion.gouv.fr"])
  end

  it "renders the body with greeting, counts, sender and tracked CTA" do
    body = mail.body.encoded.gsub(/\s+/, " ")

    expect(body).to include("Jean MARTIN,")
                .and include("28 usagers sont prêts à être invités")
                .and include("seulement 26 créneaux sont disponibles")
                .and include("L'ouverture de 2 créneaux supplémentaires")
                .and include("Maria DUPUIS")
                .and include("Ouvrir des créneaux")
                .and include("/c/#{creneau_opening_request.uuid}")
  end
end
