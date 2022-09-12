describe ArchivedApplicantsController, type: :controller do
  let!(:department) { create(:department) }
  let!(:configuration) do
    create(
      :configuration,
      motif_category: "rsa_orientation",
      number_of_days_before_action_required: number_of_days_before_action_required
    )
  end
  let!(:number_of_days_before_action_required) { 3 }
  let!(:organisation) do
    create(:organisation, rdv_solidarites_organisation_id: rdv_solidarites_organisation_id,
                          department_id: department.id, configurations: [configuration])
  end
  let!(:agent) { create(:agent, organisations: [organisation]) }
  let!(:rdv_solidarites_organisation_id) { 52 }
  let!(:rdv_solidarites_session) { instance_double(RdvSolidaritesSession) }
  let(:applicant) { create(:applicant, organisations: [organisation], department: department) }

  describe "#index" do
    let!(:applicant) do
      create(
        :applicant,
        organisations: [organisation], department: department, last_name: "Chabat",
        rdv_contexts: [rdv_context1], is_archived: true
      )
    end
    let!(:rdv_context1) { build(:rdv_context, motif_category: "rsa_orientation", status: "rdv_seen") }

    let!(:applicant2) do
      create(
        :applicant,
        organisations: [organisation], department: department, last_name: "Baer",
        rdv_contexts: [rdv_context2], is_archived: true
      )
    end
    let!(:rdv_context2) { build(:rdv_context, motif_category: "rsa_orientation", status: "invitation_pending") }

    let!(:applicant3) do
      create(
        :applicant,
        organisations: [organisation], department: department, last_name: "Darmon", rdv_contexts: [rdv_context3]
      )
    end
    let!(:rdv_context3) { build(:rdv_context, motif_category: "rsa_orientation", status: "invitation_pending") }

    let!(:index_params) { { organisation_id: organisation.id } }

    render_views

    before do
      sign_in(agent)
      setup_rdv_solidarites_session(rdv_solidarites_session)
    end

    it "returns a list of archived applicants" do
      get :index, params: index_params

      expect(response).to be_successful
      expect(response.body).to match(/Chabat/)
      expect(response.body).to match(/Baer/)
      expect(response.body).not_to match(/Darmon/)
    end

    context "when a search query is specified" do
      let!(:index_params) do
        { organisation_id: organisation.id, search_query: "chabat", motif_category: "rsa_orientation" }
      end

      it "searches the applicants" do
        get :index, params: index_params
        expect(response.body).to match(/Chabat/)
        expect(response.body).not_to match(/Baer/)
      end
    end

    context "when a status is passed" do
      let!(:index_params) do
        { organisation_id: organisation.id, status: "invitation_pending", motif_category: "rsa_orientation" }
      end

      it "filters by status" do
        get :index, params: index_params
        expect(response.body).to match(/Baer/)
        expect(response.body).not_to match(/Chabat/)
      end
    end

    context "when dates are passed" do
      let!(:invitation1) do
        create(:invitation, sent_at: DateTime.new(2022, 6, 1, 10, 0), rdv_context: rdv_context1, applicant: applicant)
      end
      let!(:invitation2) do
        create(:invitation, sent_at: DateTime.new(2022, 6, 8, 10, 0), rdv_context: rdv_context2, applicant: applicant2)
      end
      let!(:invitation3) do
        create(:invitation, sent_at: DateTime.new(2022, 6, 15, 10, 0), rdv_context: rdv_context3, applicant: applicant3)
      end

      context "for first invitations" do
        let!(:index_params) do
          { organisation_id: organisation.id, motif_category: "rsa_orientation",
            first_invitation_date_after: "05-06-2022", first_invitation_date_before: "10-06-2022" }
        end

        it "filters by first invitations dates" do
          get :index, params: index_params
          expect(response.body).to match(/Baer/)
          expect(response.body).not_to match(/Chabat/)
          expect(response.body).not_to match(/Darmon/)
        end
      end

      context "for last invitations" do
        let!(:invitation4) do
          create(:invitation, sent_at: DateTime.new(2022, 6, 16, 10, 0),
                              rdv_context: rdv_context1, applicant: applicant)
        end
        let!(:invitation5) do
          create(:invitation, sent_at: DateTime.new(2022, 6, 17, 10, 0),
                              rdv_context: rdv_context2, applicant: applicant2)
        end

        let!(:index_params) do
          { organisation_id: organisation.id, motif_category: "rsa_orientation",
            last_invitation_date_after: "17-06-2022", last_invitation_date_before: "17-06-2022" }
        end

        it "filters by last invitations dates" do
          get :index, params: index_params
          expect(response.body).to match(/Baer/)
          expect(response.body).not_to match(/Chabat/)
        end
      end
    end

    context "when department level" do
      let!(:index_params) { { department_id: department.id, motif_category: "rsa_orientation" } }

      it "renders the index page" do
        get :index, params: index_params

        expect(response.body).to match(/Chabat/)
        expect(response.body).to match(/Baer/)
        expect(response.body).not_to match(/Darmon/)
      end
    end

    context "when csv request" do
      before do
        allow(GenerateApplicantsCsv).to receive(:call)
          .and_return(OpenStruct.new)
      end

      it "calls the service" do
        expect(GenerateApplicantsCsv).to receive(:call)
        get :index, params: index_params.merge(format: :csv)
      end

      context "when not authorized" do
        let!(:another_organisation) { create(:organisation) }
        let!(:another_agent) { create(:agent, organisations: [another_organisation]) }

        before do
          sign_in(another_agent)
          setup_rdv_solidarites_session(rdv_solidarites_session)
        end

        it "does not call the service" do
          expect do
            get :index, params: index_params.merge(format: :csv)
          end.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "when the csv creation succeeds" do
        before do
          allow(GenerateApplicantsCsv).to receive(:call)
            .and_return(OpenStruct.new(success?: true))
        end

        it "is a success" do
          get :index, params: index_params.merge(format: :csv)
          expect(response).to be_successful
        end
      end
    end
  end
end
