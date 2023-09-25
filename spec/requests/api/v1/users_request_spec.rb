describe "Users API" do
  let!(:agent) { create(:agent, organisations: [organisation]) }
  let!(:rdv_solidarites_organisation_id) { 42 }
  let!(:organisation) do
    create(:organisation, rdv_solidarites_organisation_id: rdv_solidarites_organisation_id)
  end
  let!(:configuration) do
    create(:configuration, organisation: organisation, motif_category: create(:motif_category, name: "RSA orientation"))
  end
  let!(:users_params) { { users: [user1_params, user2_params] } }

  let!(:user1_params) do
    {
      first_name: "Didier",
      last_name: "Drogba",
      title: "monsieur",
      affiliation_number: "10492390",
      role: "demandeur",
      email: "didier@drogba.com",
      phone_number: "0782605941",
      birth_date: "11/03/1978",
      address: "13 rue de la République 13001 MARSEILLE",
      department_internal_id: "11111444",
      invitation: {
        rdv_solidarites_lieu_id: 363
      }
    }
  end

  let!(:user2_params) do
    {
      first_name: "Dimitri",
      last_name: "Payet",
      title: "monsieur",
      affiliation_number: "0782605941",
      role: "conjoint",
      email: "amine.dhobb+testapi2@gmail.com",
      phone_number: "0782605941",
      birth_date: "29/03/1987",
      rights_opening_date: "15/11/2021",
      address: "5 Avenue du Moulin des Baux, 13260 Cassis",
      department_internal_id: "22221111",
      pole_emploi_id: "22233333",
      invitation: {
        rdv_solidarites_lieu_id: 363,
        motif_category_name: "RSA orientation"
      }
    }
  end

  describe "POST api/v1/organisations/:rdv_solidarites_organisation_id/users/create_and_invite_many" do
    subject do
      post(
        create_and_invite_many_api_v1_users_path(rdv_solidarites_organisation_id: rdv_solidarites_organisation_id),
        params: users_params, headers: api_auth_headers_for_agent(agent), as: :json
      )
    end

    before do
      sign_in(agent, for_api: true)
      allow(CreateAndInviteUserJob).to receive(:perform_async)
    end

    it "enqueues create and invite jobs" do
      expect(CreateAndInviteUserJob).to receive(:perform_async)
        .with(
          organisation.id,
          user1_params.except(:invitation),
          user1_params[:invitation],
          session_hash(agent.email)
        )
      expect(CreateAndInviteUserJob).to receive(:perform_async)
        .with(
          organisation.id,
          user2_params.except(:invitation),
          user2_params[:invitation],
          session_hash(agent.email)
        )
      subject
    end

    it "is a success" do
      subject
      expect(response).to have_http_status(:ok)
      result = response.parsed_body
      expect(result["success"]).to eq(true)
    end

    context "with 'users' instead of 'users' in payload" do
      subject do
        post(
          create_and_invite_many_api_v1_users_path(
            rdv_solidarites_organisation_id: rdv_solidarites_organisation_id
          ),
          params: users_payload, headers: api_auth_headers_for_agent(agent), as: :json
        )
      end

      let!(:users_payload) { { users: [user1_params, user2_params] } }

      it "enqueues create and invite jobs" do
        expect(CreateAndInviteUserJob).to receive(:perform_async)
          .with(
            organisation.id,
            user1_params.except(:invitation),
            user1_params[:invitation],
            session_hash(agent.email)
          )
        expect(CreateAndInviteUserJob).to receive(:perform_async)
          .with(
            organisation.id,
            user2_params.except(:invitation),
            user2_params[:invitation],
            session_hash(agent.email)
          )
        subject
      end

      it "is a success" do
        subject
        expect(response).to have_http_status(:ok)
        result = response.parsed_body
        expect(result["success"]).to eq(true)
      end
    end

    context "when session is invalid" do
      before do
        allow(rdv_solidarites_session).to receive(:valid?).and_return(false)
      end

      it "returns unauthorized" do
        subject
        expect(response).to have_http_status(:unauthorized)
        result = response.parsed_body
        expect(result["errors"]).to eq(["Les identifiants de session RDV-Solidarités sont invalides"])
      end

      it "does not enqueue jobs" do
        expect(CreateAndInviteUserJob).not_to receive(:perform_async)
        subject
      end
    end

    context "when it fails to retrieve the agent" do
      before do
        allow(rdv_solidarites_session).to receive(:uid).and_return("nonexistingagent@beta.gouv.fr")
      end

      it "returns 422" do
        subject
        expect(response).not_to be_successful
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["success"]).to eq(false)
        expect(response.parsed_body["errors"]).to eq(
          ["L'agent ne fait pas partie d'une organisation sur RDV-Insertion"]
        )
      end
    end

    context "when organisation is not found" do
      let!(:organisation) { create(:organisation, rdv_solidarites_organisation_id: 5000) }

      it "returns 404" do
        subject
        expect(response).to have_http_status(:not_found)
      end
    end

    context "with no invitation attributes" do
      before { user1_params.delete(:invitation) }

      it "is a success" do
        expect(CreateAndInviteUserJob).to receive(:perform_async)
          .with(
            organisation.id,
            user1_params,
            {},
            session_hash(agent.email)
          )
        subject
        expect(response).to have_http_status(:ok)
        result = response.parsed_body
        expect(result["success"]).to eq(true)
      end

      context "when there is more than one motif category" do
        let!(:new_configuration) do
          create(
            :configuration,
            motif_category: create(:motif_category, name: "RSA accompagnement"),
            organisation: organisation
          )
        end

        it "returns 422" do
          subject
          expect(response).to have_http_status(:unprocessable_entity)
          result = response.parsed_body
          expect(result["errors"]).to include(
            { "Entrée 1" => { "motif_category_name" => ["La catégorie de motifs doit être précisée"] } }
          )
        end
      end
    end

    context "when params are invalid" do
      context "with invalid users attributes" do
        before do
          user1_params[:last_name] = ""
          user2_params[:department_internal_id] = ""
        end

        it "returns 422" do
          subject
          expect(response).to have_http_status(:unprocessable_entity)
          result = response.parsed_body
          expect(result["errors"]).to include({ "Entrée 1 - 11111444" => { "last_name" => ["doit être rempli(e)"] } })
        end

        it "does not enqueue jobs" do
          expect(CreateAndInviteUserJob).not_to receive(:perform_async)
          subject
        end
      end

      context "with too many users" do
        let!(:users_params) do
          { users: 30.times.map { user1_params } }
        end

        it "returns 422" do
          subject
          expect(response).to have_http_status(:unprocessable_entity)
          result = response.parsed_body
          expect(result["errors"]).to include("Les usagers doivent être envoyés par lots de 25 maximum")
        end

        it "does not enqueue jobs" do
          expect(CreateAndInviteUserJob).not_to receive(:perform_async)
          subject
        end
      end

      context "with invalid invitation context for organisation" do
        before do
          user1_params[:invitation][:motif_category_name] = "RSA accompagnement"
        end

        it "returns 422" do
          subject
          expect(response).to have_http_status(:unprocessable_entity)
          result = response.parsed_body
          expect(result["errors"]).to include(
            { "Entrée 1" => { "motif_category_name" => ["Catégorie de motifs RSA accompagnement invalide"] } }
          )
        end

        it "does not enqueue jobs" do
          expect(CreateAndInviteUserJob).not_to receive(:perform_async)
          subject
        end
      end
    end

    context "for existing user" do
      let!(:user) { create(:user, pole_emploi_id: "22233333") }

      it "is a success" do
        subject
        expect(response).to have_http_status(:ok)
        result = response.parsed_body
        expect(result["success"]).to eq(true)
      end
    end

    context "when not authorized" do
      let!(:other_org) { create(:organisation) }
      let!(:agent) { create(:agent, organisations: [other_org]) }

      it "returns 403" do
        subject
        expect(response).to have_http_status(:forbidden)
        result = response.parsed_body
        expect(result["errors"]).to eq(["Votre compte ne vous permet pas d'effectuer cette action"])
      end
    end
  end
end
