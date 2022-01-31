describe "api/v1/applicants/create_and_invite_many requests", type: :request do
  let!(:rdv_solidarites_session) { instance_double(RdvSolidaritesSession) }
  let!(:rdv_solidarites_organisation_id) { 42 }
  let!(:organisation) { create(:organisation, rdv_solidarites_organisation_id: rdv_solidarites_organisation_id) }
  let!(:applicants_params) { { applicants: [applicant1_params, applicant2_params] } }

  let!(:applicant1_params) do
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

  let!(:applicant2_params) do
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
      invitation: {
        rdv_solidarites_lieu_id: 363
      }
    }
  end

  describe "GET api/v1/organisations/:rdv_solidarites_organisation_id/applicants/create_and_invite_many" do
    subject do
      post(
        create_and_invite_many_api_v1_applicants_path(rdv_solidarites_organisation_id: rdv_solidarites_organisation_id),
        params: applicants_params, headers: api_auth_headers, as: :json
      )
    end

    before do
      validate_rdv_solidarites_session(rdv_solidarites_session)
      allow(CreateAndInviteApplicantJob).to receive(:perform_async)
    end

    it "enqueues create and invite jobs" do
      expect(CreateAndInviteApplicantJob).to receive(:perform_async)
        .with(organisation.id, applicant1_params.except(:invitation), applicant1_params[:invitation], session_hash)
      expect(CreateAndInviteApplicantJob).to receive(:perform_async)
        .with(organisation.id, applicant2_params.except(:invitation), applicant2_params[:invitation], session_hash)
      subject
    end

    it "is a success" do
      subject
      expect(response.status).to eq(200)
      result = JSON.parse(response.body)
      expect(result["success"]).to eq(true)
    end

    context "when session is invalid" do
      before do
        allow(rdv_solidarites_session).to receive(:valid?).and_return(false)
      end

      it "returns unauthorized" do
        subject
        expect(response.status).to eq(401)
        result = JSON.parse(response.body)
        expect(result["errors"]).to eq(["Les identifiants de session RDV-Solidarités sont invalides"])
      end

      it "does not enqueue jobs" do
        expect(CreateAndInviteApplicantJob).not_to receive(:perform_async)
        subject
      end
    end

    context "when organisation is not found" do
      let!(:organisation) { create(:organisation, rdv_solidarites_organisation_id: 5000) }

      it "returns 404" do
        subject
        expect(response.status).to eq(404)
      end
    end

    context "when params are invalid" do
      before do
        applicant1_params[:last_name] = ""
        applicant2_params[:department_internal_id] = ""
      end

      it "returns 422" do
        subject
        expect(response.status).to eq(422)
        result = JSON.parse(response.body)
        expect(result["errors"]).to include({ "Entrée 1 - 11111444" => { "last_name" => ["doit être rempli(e)"] } })
        expect(result["errors"]).to include({ "Entrée 2" => { "department_internal_id" => ["doit être rempli(e)"] } })
      end

      it "does not enqueue jobs" do
        expect(CreateAndInviteApplicantJob).not_to receive(:perform_async)
        subject
      end
    end
  end
end
