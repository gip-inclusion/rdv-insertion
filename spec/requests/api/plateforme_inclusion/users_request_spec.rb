describe "Plateforme de l'inclusion users search" do
  subject { post "/api/plateforme_inclusion/users/search", params: { nir: nir_param }, headers:, as: :json }

  let(:headers) { { "Authorization" => "Bearer plateforme_inclusion_api_token", "X-Forwarded-For" => forwarded_for } }
  let(:forwarded_for) { "91.208.207.10" }
  let(:nir_param) { nir }
  let!(:nir) { generate_random_nir }
  let!(:organisation) { create(:organisation) }
  let!(:user) { create(:user, nir:, organisations: [organisation]) }
  let!(:follow_up) { create(:follow_up, user:) }
  let!(:rdv) { create(:rdv, organisation:) }
  let!(:participation) { create(:participation, rdv:, user:, follow_up:) }
  let!(:other_participant) { rdv.users.where.not(id: user.id).first }

  before do
    allow(Sentry).to receive(:capture_message)
    allow(Rails.logger).to receive(:info).and_call_original
  end

  it "returns the user matching the nir" do
    subject
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.dig("user", "id")).to eq(user.id)
  end

  it "logs the returned user with the IP of the request" do
    subject
    expect(Rails.logger).to have_received(:info).with(
      "[PlateformeInclusion] User returned: user_id=#{user.id} ip=91.208.207.10"
    )
  end

  it "returns the rdvs of the user through its follow-ups" do
    subject
    participation_json = response.parsed_body.dig("user", "follow_ups", 0, "participations", 0)
    expect(participation_json["id"]).to eq(participation.id)
    expect(participation_json.dig("rdv", "id")).to eq(rdv.id)
  end

  it "returns the motif category type of the follow-ups" do
    subject
    motif_category_json = response.parsed_body.dig("user", "follow_ups", 0, "motif_category")
    expect(motif_category_json["motif_category_type"]).to eq("rsa_orientation")
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

  context "when the nir param holds several values" do
    let(:nir_param) { [generate_random_nir, nir] }

    it "returns a bad request without any user data" do
      subject
      expect(response).to have_http_status(:bad_request)
      expect(response.parsed_body).to eq("errors" => ["Le paramètre nir doit contenir un seul NIR"])
    end
  end

  context "when the nir param is missing" do
    let(:nir_param) { nil }

    it "returns a bad request" do
      subject
      expect(response).to have_http_status(:bad_request)
    end
  end

  context "when the token is invalid" do
    let(:headers) { { "Authorization" => "Bearer invalid_token", "X-Forwarded-For" => "203.0.113.50" } }

    it "returns unauthorized" do
      subject
      expect(response).to have_http_status(:unauthorized)
    end

    it "notifies Sentry with the IP of the request" do
      subject
      expect(Sentry).to have_received(:capture_message).with(
        "Plateforme de l'inclusion search without a valid token", extra: { ip: "203.0.113.50" }
      )
    end
  end

  context "when no token is provided" do
    let(:headers) { { "X-Forwarded-For" => "203.0.113.50" } }

    it "returns unauthorized" do
      subject
      expect(response).to have_http_status(:unauthorized)
    end

    it "notifies Sentry with the IP of the request" do
      subject
      expect(Sentry).to have_received(:capture_message).with(
        "Plateforme de l'inclusion search without a valid token", extra: { ip: "203.0.113.50" }
      )
    end
  end

  context "when a valid token comes from an IP outside the Clever Cloud ranges" do
    let(:forwarded_for) { "203.0.113.50" }

    it "returns forbidden without any user data" do
      subject
      expect(response).to have_http_status(:forbidden)
      expect(response.parsed_body).to eq("errors" => ["Cette adresse IP n'est pas autorisée"])
    end

    it "notifies Sentry with the IP of the request" do
      subject
      expect(Sentry).to have_received(:capture_message).with(
        "Plateforme de l'inclusion search with a valid token from a non whitelisted IP", extra: { ip: "203.0.113.50" }
      )
    end

    context "when the IP whitelist is disabled" do
      before { ENV["DISABLE_PLATEFORME_INCLUSION_IP_WHITELIST"] = "true" }
      after { ENV["DISABLE_PLATEFORME_INCLUSION_IP_WHITELIST"] = nil }

      it "returns the user" do
        subject
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body.dig("user", "id")).to eq(user.id)
      end
    end
  end

  context "when the client sends a Clever Cloud IP on the left of X-Forwarded-For" do
    let(:forwarded_for) { "91.208.207.10, 203.0.113.50" }

    it "returns forbidden" do
      subject
      expect(response).to have_http_status(:forbidden)
    end
  end
end
