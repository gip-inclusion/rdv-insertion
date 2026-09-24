describe "Plateforme de l'inclusion users search" do
  subject { post "/api/plateforme_inclusion/users/search", params: { nir: }, headers:, as: :json }

  let(:headers) { { "Authorization" => "Bearer plateforme_inclusion_api_token" } }
  let!(:nir) { generate_random_nir }
  let!(:organisation) { create(:organisation) }
  let!(:user) { create(:user, nir:, organisations: [organisation]) }
  let!(:follow_up) { create(:follow_up, user:) }
  let!(:rdv) { create(:rdv, organisation:) }
  let!(:participation) { create(:participation, rdv:, user:, follow_up:) }
  let!(:other_participant) { rdv.users.where.not(id: user.id).first }

  before { allow(Sentry).to receive(:capture_message) }

  it "returns the user matching the nir" do
    subject
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.dig("user", "id")).to eq(user.id)
  end

  it "returns the rdvs of the user through its follow-ups" do
    subject
    participation_json = response.parsed_body.dig("user", "follow_ups", 0, "participations", 0)
    expect(participation_json["id"]).to eq(participation.id)
    expect(participation_json.dig("rdv", "id")).to eq(rdv.id)
  end

  it "does not return the other participants of the rdv" do
    subject
    expect(response.body).not_to include(other_participant.email)
  end

  context "when the user has several organisations, follow-ups, invitations and rdvs" do
    let!(:other_organisation) { create(:organisation) }
    let!(:user) do
      create(:user, nir:, organisations: [organisation, other_organisation],
                    referents: create_list(:agent, 2), tags: create_list(:tag, 2))
    end

    before do
      create(:archive, user:, organisation:)
      create(:archive, user:, organisation: other_organisation)
      create_list(:follow_up, 2, user:).each do |other_follow_up|
        create_list(:invitation, 2, user:, follow_up: other_follow_up)
        create_list(:participation, 2, user:, follow_up: other_follow_up)
      end
    end

    it "does not trigger N+1 queries" do
      Prosopite.enabled = true
      Prosopite.raise = true
      Prosopite.scan
      begin
        subject
        Prosopite.finish
      ensure
        Prosopite.enabled = false
        Prosopite.raise = false
      end
      expect(response).to have_http_status(:ok)
    end
  end

  context "when no user matches the nir" do
    let!(:user) { create(:user, organisations: [organisation]) }

    it "returns not found" do
      subject
      expect(response).to have_http_status(:not_found)
    end
  end

  context "when several users match the nir" do
    let!(:other_user) { create(:user, nir:, organisations: [create(:organisation)]) }

    it "returns a conflict without any user data" do
      subject
      expect(response).to have_http_status(:conflict)
      expect(response.parsed_body).not_to have_key("user")
    end

    it "notifies Sentry with the matching users" do
      subject
      expect(Sentry).to have_received(:capture_message).with(
        "Several users match the NIR searched by plateforme de l'inclusion",
        extra: { user_ids: contain_exactly(user.id, other_user.id) }
      )
    end
  end

  context "when the token is invalid" do
    let(:headers) { { "Authorization" => "Bearer invalid_token" } }

    it "returns unauthorized" do
      subject
      expect(response).to have_http_status(:unauthorized)
    end
  end

  context "when no token is provided" do
    let(:headers) { {} }

    it "returns unauthorized" do
      subject
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
