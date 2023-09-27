describe UsersController do
  let!(:department) { create(:department) }
  let!(:category_orientation) do
    create(:motif_category, short_name: "rsa_orientation", name: "RSA orientation")
  end
  let!(:category_accompagnement) do
    create(:motif_category, short_name: "rsa_accompagnement", name: "RSA accompagnement")
  end
  let!(:configuration) do
    create(
      :configuration,
      motif_category: category_orientation,
      number_of_days_before_action_required: number_of_days_before_action_required
    )
  end
  let!(:number_of_days_before_action_required) { 6 }
  let!(:organisation) do
    create(:organisation, rdv_solidarites_organisation_id: rdv_solidarites_organisation_id,
                          department_id: department.id, configurations: [configuration])
  end
  let!(:agent) { create(:agent, basic_role_in_organisations: [organisation]) }
  let!(:rdv_solidarites_organisation_id) { 888 }
  let(:user) { create(:user, organisations: [organisation]) }

  render_views

  before do
    sign_in(agent)
  end

  describe "#new" do
    let!(:new_params) { { organisation_id: organisation.id } }

    it "renders the new user page" do
      get :new, params: new_params

      expect(response).to be_successful
      expect(response.body).to match(/Créer un usager/)
    end
  end

  describe "#create" do
    before do
      allow(Users::FindOrInitialize).to receive(:call)
        .and_return(OpenStruct.new(success?: true, user: user))
      allow(User).to receive(:new)
        .and_return(user)
      allow(user).to receive(:assign_attributes)
      allow(Users::Save).to receive(:call)
        .and_return(OpenStruct.new(success?: true))
    end

    let(:user_params) do
      {
        user: {
          uid: "123xz", first_name: "john", last_name: "doe", email: "johndoe@example.com",
          affiliation_number: "1234", role: "conjoint"
        },
        organisation_id: organisation.id
      }
    end

    it "calls the Users::FindOrInitialize service" do
      expect(Users::FindOrInitialize).to receive(:call)
      post :create, params: user_params
    end

    it "assigns the attributes" do
      expect(user).to receive(:assign_attributes)
      post :create, params: user_params
    end

    it "calls the Users::Save service" do
      expect(Users::Save).to receive(:call)
      post :create, params: user_params
    end

    context "when html request" do
      let(:user_params) do
        {
          user: {
            first_name: "john", last_name: "doe", email: "johndoe@example.com",
            affiliation_number: "1234", role: "demandeur", title: "monsieur"
          },
          organisation_id: organisation.id,
          format: "html"
        }
      end

      context "when not authorized" do
        let!(:another_organisation) { create(:organisation) }

        it "raises an error" do
          expect do
            post :create, params: user_params.merge(organisation_id: another_organisation.id)
          end.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "when the creation succeeds" do
        it "is a success" do
          post :create, params: user_params
          expect(response).to redirect_to(organisation_user_path(organisation, user))
        end
      end

      context "when the creation fails" do
        before do
          allow(Users::Save).to receive(:call)
            .and_return(OpenStruct.new(success?: false, errors: ["some error"]))
        end

        it "renders the new page" do
          post :create, params: user_params
          expect(response).not_to be_successful
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to match(/Créer un usager/)
        end
      end
    end

    context "when json request" do
      before { request.accept = "application/json" }

      let(:user_params) do
        {
          user: {
            uid: "123xz", first_name: "john", last_name: "doe", email: "johndoe@example.com",
            affiliation_number: "1234", role: "conjoint"
          },
          organisation_id: organisation.id
        }
      end

      context "when not authorized" do
        let!(:another_organisation) { create(:organisation) }

        it "raises an error" do
          expect do
            post :create, params: user_params.merge(organisation_id: another_organisation.id)
          end.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "when the creation succeeds" do
        let!(:user) { create(:user, organisations: [organisation]) }

        it "is a success" do
          post :create, params: user_params
          expect(response).to be_successful
          expect(response.parsed_body["success"]).to eq(true)
        end

        it "renders the user" do
          post :create, params: user_params
          expect(response).to be_successful
          expect(response.parsed_body["user"]["id"]).to eq(user.id)
        end
      end

      context "when the creation fails" do
        before do
          allow(Users::Save).to receive(:call)
            .and_return(OpenStruct.new(success?: false, errors: ["some error"]))
        end

        it "is not a success" do
          post :create, params: user_params
          expect(response).not_to be_successful
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body["success"]).to eq(false)
        end

        it "renders the errors" do
          post :create, params: user_params
          expect(response).not_to be_successful
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body["errors"]).to eq(["some error"])
        end
      end
    end
  end

  describe "#show" do
    let!(:user) do
      create(
        :user, first_name: "Andreas", last_name: "Kopke", organisations: [organisation]
      )
    end
    let!(:show_params) { { id: user.id, organisation_id: organisation.id } }

    context "when organisation_level" do
      it "renders the user page" do
        get :show, params: show_params

        expect(response).to be_successful
        expect(response.body).to match(/Voir sur RDV-Solidarités/)
        expect(response.body).to match(/Andreas/)
        expect(response.body).to match(/Kopke/)
      end
    end

    context "when department_level" do
      let!(:show_params) { { id: user.id, department_id: department.id } }

      it "renders the user page" do
        get :show, params: show_params

        expect(response).to be_successful
        expect(response.body).to match(/Voir sur RDV-Solidarités/)
        expect(response.body).to match(/Andreas/)
        expect(response.body).to match(/Kopke/)
      end
    end

    context "when user is archived" do
      let!(:user) { create(:user, organisations: [organisation]) }
      let!(:archive) { create(:archive, user: user, department: department) }
      let!(:show_params) { { id: user.id, organisation_id: organisation.id } }

      it "the user is displayed as archived" do
        get :show, params: show_params

        expect(response).to be_successful
        expect(response.body).to match(/Dossier archivé/)
        expect(response.body).to match(/Motif d&#39;archivage/)
      end
    end

    context "it shows the different contexts" do
      let!(:configuration) do
        create(:configuration, motif_category: category_orientation, invitation_formats: %w[sms email])
      end
      let!(:configuration2) do
        create(:configuration, motif_category: category_accompagnement, invitation_formats: %w[sms email postal])
      end

      let!(:organisation) do
        create(:organisation, rdv_solidarites_organisation_id: rdv_solidarites_organisation_id,
                              configurations: [configuration, configuration2], department_id: department.id)
      end

      let!(:rdv_context) do
        create(:rdv_context, status: "rdv_seen", user: user, motif_category: category_orientation)
      end
      let!(:invitation_orientation) do
        create(:invitation, sent_at: "2021-10-20", format: "sms", rdv_context: rdv_context)
      end

      let!(:motif) { create(:motif, name: "RSA Orientation sur site") }

      let!(:rdv_orientation1) do
        create(
          :rdv,
          starts_at: "2021-10-22", motif: motif,
          organisation: organisation
        )
      end
      let!(:participation) do
        create(
          :participation,
          rdv: rdv_orientation1, rdv_context: rdv_context, user: user, status: "noshow",
          created_at: "2021-10-21"
        )
      end

      let!(:rdv_orientation2) do
        create(
          :rdv,
          starts_at: "2021-10-24", motif: motif, organisation: organisation
        )
      end
      let!(:participation2) do
        create(
          :participation,
          rdv_context: rdv_context, rdv: rdv_orientation2, user: user, status: "seen",
          created_at: "2021-10-23"
        )
      end

      let!(:rdv_context2) do
        create(
          :rdv_context, status: "invitation_pending", user: user, motif_category: category_accompagnement
        )
      end

      let!(:invitation_accompagnement) do
        create(:invitation, sent_at: "2021-11-20", format: "sms", rdv_context: rdv_context2)
      end

      it "shows all the contexts" do
        get :show, params: show_params

        expect(response).to be_successful
        expect(response.body).to match(/RSA orientation/)
        expect(response.body).to match(/RSA accompagnement/)
        expect(response.body).to match(/RDV honoré/)
        expect(response.body).to match(/RDV pris le/)
        expect(response.body).to match(/Date du RDV/)
        expect(response.body).to match(/Statut RDV/)
        expect(response.body).to include("21/10/2021")
        expect(response.body).to include("22/10/2021")
        expect(response.body).to include("23/10/2021")
        expect(response.body).to include("24/10/2021")
        expect(response.body).to match(/Absence non excusée/)
        expect(response.body).to match(/Rendez-vous honoré/)
        expect(response.body).to match(/Statut RDV/)
        expect(response.body).to match(/Invitation en attente de réponse/)
        expect(response.body).to match(/RSA Orientation sur site/)
        expect(response.body).not_to match(/Convoqué par/)
      end

      context "when a rdv_context is not open" do
        let!(:rdv_context2) { nil }
        let!(:invitation_accompagnement) { nil }

        it "show the open rdv_context button" do
          get :show, params: show_params

          expect(unescaped_response_body).to match("class=\"simple_form rdv_context\"")
          expect(unescaped_response_body).to match("input value=\"#{user.id}\"")
          expect(unescaped_response_body).to match("input value=\"#{category_accompagnement.id}\"")
          expect(unescaped_response_body).to match(/Ouvrir un suivi/)
        end
      end

      context "when one rdv is a convocation" do
        before { participation.update!(convocable: true) }

        let!(:notification) do
          create(
            :notification,
            participation: participation, event: "participation_created", format: "sms",
            sent_at: 2.days.ago
          )
        end

        it "shows the convocation formats" do
          get :show, params: show_params

          expect(response.body).to match(/Convoqué par/)
          expect(response.body).to include("SMS 📱")
          expect(response.body).not_to include("Email 📧")
        end

        context "when the rdv is pending" do
          before do
            rdv_orientation1.update! starts_at: 2.days.from_now
            participation.update! status: "unknown"
          end

          it "shows the courrier generation button" do
            get :show, params: show_params

            expect(response.body).to include("<i class=\"fas fa-file-pdf\"></i> Courrier")
          end
        end

        context "when the rdv is passed" do
          context "when the participation is revoked" do
            before { participation.update! status: "revoked" }

            it "shows the courrier generation button" do
              get :show, params: show_params

              expect(response.body).to include("<i class=\"fas fa-file-pdf\"></i> Courrier")
            end
          end

          context "when the rdv participation is seen" do
            before { participation.update! status: "seen" }

            it "does not show the courrier generation button" do
              get :show, params: show_params

              expect(response.body).not_to include("<i class=\"fas fa-file-pdf\"></i> Courrier")
            end
          end
        end
      end

      context "when there is no matching configuration for a rdv_context" do
        let!(:organisation) do
          create(:organisation, rdv_solidarites_organisation_id: rdv_solidarites_organisation_id,
                                department_id: department.id, configurations: [configuration2])
        end

        let!(:rdv_context) do
          create(:rdv_context, status: "rdv_seen", user: user, motif_category: category_orientation)
        end

        it "does not display the context" do
          get :show, params: show_params

          expect(response).to be_successful
          expect(response.body).to match(/InvitationBlock/)
          expect(response.body).not_to match(/RSA orientation/)
        end
      end
    end
  end

  describe "#default_list" do
    context "when department_level" do
      let!(:index_params) { { department_id: department.id } }

      context "when department has no motif_categories" do
        let!(:organisation) { create(:organisation, department: department, configurations: []) }

        it "redirects to the department_users_paths with no params" do
          get :default_list, params: index_params

          expect(response).to redirect_to(department_users_path(department))
        end
      end

      context "when department has one motif_category" do
        let!(:category_orientation) do
          create(:motif_category, short_name: "rsa_orientation", name: "RSA orientation")
        end
        let!(:configuration) { create(:configuration, motif_category: category_orientation) }
        let!(:organisation) { create(:organisation, department: department, configurations: [configuration]) }

        it "redirects to the motif_category index" do
          get :default_list, params: index_params

          expect(response).to redirect_to(
            department_users_path(department, motif_category_id: category_orientation.id)
          )
        end
      end

      context "when department has multiple motif_categories" do
        let!(:category_orientation) do
          create(:motif_category, short_name: "rsa_orientation", name: "RSA orientation")
        end
        let!(:category_accompagnement) do
          create(:motif_category, short_name: "rsa_accompagnement", name: "RSA accompagnement")
        end
        let!(:configuration) { create(:configuration, motif_category: category_orientation) }
        let!(:configuration2) { create(:configuration, motif_category: category_accompagnement) }
        let!(:organisation) do
          create(:organisation, department: department, configurations: [configuration, configuration2])
        end

        it "redirects to the department_users_paths with no params" do
          get :default_list, params: index_params

          expect(response).to redirect_to(department_users_path(department))
        end
      end
    end

    context "when organisation level" do
      let!(:index_params) { { organisation_id: organisation.id } }

      context "when organisation has no motif_categories" do
        let!(:organisation) { create(:organisation, department: department, configurations: []) }

        it "redirects to the organisation_users_paths with no params" do
          get :default_list, params: index_params

          expect(response).to redirect_to(organisation_users_path(organisation))
        end
      end

      context "when organisation has one motif_category" do
        let!(:category_orientation) do
          create(:motif_category, short_name: "rsa_orientation", name: "RSA orientation")
        end
        let!(:configuration) { create(:configuration, motif_category: category_orientation) }
        let!(:organisation) { create(:organisation, department: department, configurations: [configuration]) }

        it "redirects to the motif_category index" do
          get :default_list, params: index_params

          expect(response).to redirect_to(
            organisation_users_path(organisation, motif_category_id: category_orientation.id)
          )
        end
      end

      context "when organisation has multiple motif_categories" do
        let!(:category_orientation) do
          create(:motif_category, short_name: "rsa_orientation", name: "RSA orientation")
        end
        let!(:category_accompagnement) do
          create(:motif_category, short_name: "rsa_accompagnement", name: "RSA accompagnement")
        end
        let!(:configuration) { create(:configuration, motif_category: category_orientation) }
        let!(:configuration2) { create(:configuration, motif_category: category_accompagnement) }
        let!(:organisation) do
          create(:organisation, department: department, configurations: [configuration, configuration2])
        end

        it "redirects to the organisation_users_paths with no params" do
          get :default_list, params: index_params

          expect(response).to redirect_to(organisation_users_path(organisation))
        end
      end
    end
  end

  describe "#index" do
    let!(:user) do
      create(
        :user,
        created_at: Time.zone.parse("2023-03-10 12:30"),
        organisations: [organisation], last_name: "Chabat", rdv_contexts: [rdv_context1]
      )
    end
    let!(:rdv_context1) { build(:rdv_context, motif_category: category_orientation, status: "rdv_seen") }

    let!(:user2) do
      create(
        :user,
        created_at: Time.zone.parse("2023-04-10 12:30"),
        organisations: [organisation], last_name: "Baer", rdv_contexts: [rdv_context2]
      )
    end
    let!(:rdv_context2) { build(:rdv_context, motif_category: category_orientation, status: "invitation_pending") }

    let!(:user3) do
      create(
        :user,
        created_at: Time.zone.parse("2023-05-10 12:30"),
        organisations: [organisation], last_name: "Darmon", rdv_contexts: [rdv_context3]
      )
    end
    let!(:rdv_context3) { build(:rdv_context, motif_category: category_accompagnement, status: "invitation_pending") }
    let!(:configuration2) { create(:configuration, motif_category: category_accompagnement) }

    let!(:archived_user) do
      create(
        :user,
        organisations: [organisation], last_name: "Barthelemy", rdv_contexts: [rdv_context4]
      )
    end
    let!(:archive) { create(:archive, user: archived_user, department: department) }
    let!(:rdv_context4) { build(:rdv_context, motif_category: category_orientation, status: "invitation_pending") }

    let!(:index_params) { { organisation_id: organisation.id, motif_category_id: category_orientation.id } }

    it "returns a list of users in the current context" do
      get :index, params: index_params

      expect(response).to be_successful
      expect(response.body).to match(/Chabat/)
      expect(response.body).to match(/Baer/)
      expect(response.body).not_to match(/Darmon/)
      expect(response.body).not_to match(/Barthelemy/)
    end

    it "does not display the configure organisation option" do
      get :index, params: index_params

      expect(response.body).not_to match(/Configurer l'organisation/)
    end

    context "when there is all types of rdv_contexts statuses" do
      before do
        RdvContext.statuses.each_key do |status|
          create(:rdv_context, motif_category: category_orientation,
                               status: status,
                               user: create(:user, organisations: [organisation]))
        end
      end

      it "displays all statuses in the filter list except closed" do
        get :index, params: index_params.merge(motif_category_id: category_orientation.id)
        RdvContext.statuses.each_key do |status|
          if status == "closed"
            expect(response.body).not_to match(/"#{status}"/)
          else
            expect(response.body).to match(/"#{status}"/)
          end
        end
      end
    end

    context "when the agent is admin" do
      let!(:agent) { create(:agent, admin_role_in_organisations: [organisation]) }

      before do
        sign_in(agent)
      end

      it "displays the configure organisation option" do
        get :index, params: index_params

        expect(response.body).to match(/Configurer l'organisation/)
      end
    end

    context "when no context is specified" do
      let!(:index_params) { { organisation_id: organisation.id } }

      it "returns the list of all users" do
        get :index, params: index_params

        expect(response).to be_successful
        expect(response.body).to match(/Chabat/)
        expect(response.body).to match(/Baer/)
        expect(response.body).to match(/Darmon/)
        expect(response.body).to match(/Barthelemy/)
      end

      it "displays the users creation date and the corresponding filter" do
        get :index, params: index_params

        expect(response.body).to match(/Date de création/)
        expect(response.body).to match(/Filtrer par date de création/)
      end
    end

    context "when archived users only" do
      let!(:index_params) { { organisation_id: organisation.id, users_scope: "archived" } }

      it "returns the list of archived users" do
        get :index, params: index_params

        expect(response).to be_successful
        expect(response.body).not_to match(/Chabat/)
        expect(response.body).not_to match(/Baer/)
        expect(response.body).to match(/Barthelemy/)
      end

      it "displays the users creation date and the corresponding filter" do
        get :index, params: index_params

        expect(response.body).to match(/Date de création/)
        expect(response.body).to match(/Filtrer par date de création/)
      end
    end

    context "when a search query is specified" do
      let!(:index_params) do
        { organisation_id: organisation.id, search_query: "chabat", motif_category_id: category_orientation.id }
      end

      it "searches the users" do
        get :index, params: index_params
        expect(response.body).to match(/Chabat/)
        expect(response.body).not_to match(/Baer/)
      end
    end

    context "when a status is passed" do
      let!(:index_params) do
        { organisation_id: organisation.id, status: "invitation_pending", motif_category_id: category_orientation.id }
      end

      it "filters by status" do
        get :index, params: index_params
        expect(response.body).to match(/Baer/)
        expect(response.body).not_to match(/Chabat/)
      end
    end

    context "when creation dates are passed" do
      let!(:index_params) do
        { organisation_id: organisation.id, creation_date_after: "01-04-2023", creation_date_before: "30-04-2023" }
      end

      it "filters by creation dates" do
        get :index, params: index_params
        expect(response.body).to match(/Baer/)
        expect(response.body).not_to match(/Chabat/)
        expect(response.body).not_to match(/Darmon/)
      end
    end

    context "when tags filters are passed" do
      let!(:tags) do
        [
          create(:tag, value: "tag1"),
          create(:tag, value: "tag2"),
          create(:tag, value: "tag3")
        ]
      end

      let!(:user) do
        create(
          :user,
          organisations: [organisation],
          first_name: "Michael",
          tag_users_attributes: [{ tag_id: tags[0].id }]
        )
      end

      let!(:user2) do
        create(:user, organisations: [organisation], first_name: "Marie",
                      tag_users_attributes: [{ tag_id: tags[0].id }, { tag_id: tags[1].id }])
      end

      let!(:user3) do
        create(:user, organisations: [organisation], first_name: "Oliva",
                      tag_users_attributes: [{ tag_id: tags[2].id }])
      end

      let!(:index_params) do
        { organisation_id: organisation.id, tag_ids: [tags[0].id, tags[1].id] }
      end

      it "filters by tag" do
        get :index, params: index_params
        expect(response.body).not_to match(/Michael/)
        expect(response.body).to match(/Marie/)
        expect(response.body).not_to match(/Oliva/)
      end

      context "when a single tag is given as string" do
        let!(:index_params) do
          { organisation_id: organisation.id, tag_ids: tags[2].id }
        end

        it "filters by this tag" do
          get :index, params: index_params
          expect(response.body).to match(/Oliva/)
          expect(response.body).not_to match(/Michael/)
          expect(response.body).not_to match(/Marie/)
        end
      end
    end

    context "when invitations dates are passed" do
      let!(:invitation1) do
        create(
          :invitation, sent_at: Time.zone.parse("2022-06-01 12:00"), rdv_context: rdv_context1,
                       user: user
        )
      end
      let!(:invitation2) do
        create(
          :invitation, sent_at: Time.zone.parse("2022-06-08 12:00"), rdv_context: rdv_context2, user: user2
        )
      end
      let!(:invitation3) do
        create(
          :invitation, sent_at: Time.zone.parse("2022-06-15 12:00"), rdv_context: rdv_context3, user: user3
        )
      end

      context "for first invitations" do
        let!(:index_params) do
          { organisation_id: organisation.id, motif_category_id: category_orientation.id,
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
          create(:invitation, sent_at: Time.zone.parse("2022-06-19 12:00"),
                              rdv_context: rdv_context1, user: user)
        end
        let!(:invitation5) do
          create(:invitation, sent_at: Time.zone.parse("2022-06-16 12:00"),
                              rdv_context: rdv_context2, user: user2)
        end
        let!(:invitation6) do
          create(:invitation, sent_at: Time.zone.parse("2022-06-17 12:00"),
                              rdv_context: rdv_context3, user: user3)
        end

        let!(:index_params) do
          { organisation_id: organisation.id, motif_category: category_orientation,
            last_invitation_date_after: "17-06-2022", last_invitation_date_before: "17-06-2022" }
        end

        it "filters by last invitations dates" do
          get :index, params: index_params
          expect(response.body).not_to match(/Baer/)
          expect(response.body).not_to match(/Chabat/)
          expect(response.body).to match(/Darmon/)
        end
      end
    end

    context "when action_required is passed" do
      let!(:index_params) do
        { organisation_id: organisation.id, action_required: "true", motif_category_id: category_orientation.id }
      end
      let!(:number_of_days_before_action_required) { 6 }

      context "when the invitation has been sent before the number of days before action required" do
        let!(:invitation) { create(:invitation, user: user2, rdv_context: rdv_context2, sent_at: 7.days.ago) }

        it "filters by action required" do
          get :index, params: index_params
          expect(response.body).to match(/Baer/)
          expect(response.body).not_to match(/Chabat/)
        end
      end

      context "when the invitation has been sent after the number of days defined in the configuration 3 days ago" do
        let!(:invitation) { create(:invitation, user: user2, rdv_context: rdv_context2, sent_at: 3.days.ago) }

        it "filters by action required" do
          get :index, params: index_params
          expect(response.body).not_to match(/Baer/)
          expect(response.body).not_to match(/Chabat/)
        end
      end
    end

    context "when filter_by_current_agent is passed" do
      let!(:index_params) do
        {
          organisation_id: organisation.id,
          filter_by_current_agent: "true",
          motif_category_id: category_orientation.id
        }
      end

      before { user.referents = [agent] }

      it "filters on the users assigned to the agent" do
        get :index, params: index_params
        expect(response.body).to match(/Chabat/)
        expect(response.body).not_to match(/Baer/)
        expect(response.body).not_to match(/Darmon/)
      end
    end

    context "when the organisation convene users" do
      before do
        configuration.update!(convene_user: true)
        rdv_context2.update!(motif_category: category_accompagnement)
      end

      let!(:rdv) { create(:rdv) }
      let!(:participation) do
        create(
          :participation,
          rdv: rdv,
          user: user,
          status: "unknown",
          rdv_context: rdv_context1
        )
      end
      let!(:rdv2) { create(:rdv) }
      let!(:participation2) do
        create(
          :participation,
          rdv: rdv2,
          user: user,
          status: "unknown",
          rdv_context: rdv_context2
        )
      end
      let!(:notification) do
        create(
          :notification,
          participation: participation, event: "participation_created", sent_at: Time.zone.parse("20/12/2021 12:00")
        )
      end
      let!(:notification2) do
        create(
          :notification,
          participation: participation, event: "participation_updated", sent_at: Time.zone.parse("21/12/2021 12:00")
        )
      end
      let!(:notification3) do
        create(
          :notification,
          participation: participation2, event: "participation_created", sent_at: Time.zone.parse("25/12/2021 12:00")
        )
      end

      it "shows the last sent convocation on the current motif category" do
        get :index, params: index_params

        expect(response.body).to include("Dernière convocation envoyée le")
        expect(response.body).to include("20/12/2021")
        expect(response.body).not_to include("21/12/2021")
        expect(response.body).not_to include("25/12/2021")
      end
    end

    context "when department level" do
      let!(:index_params) { { department_id: department.id, motif_category_id: category_orientation.id } }

      it "renders the index page" do
        get :index, params: index_params

        expect(response.body).to match(/Chabat/)
        expect(response.body).to match(/Baer/)
      end

      it "does not display the configure organisation option" do
        get :index, params: index_params

        expect(response.body).not_to match(/Configurer une organisation/)
      end

      context "ordering" do
        context "without motif_category" do
          let!(:index_params) do
            { department_id: department.id }
          end

          before do
            UsersOrganisation.where(user: user2).update!(created_at: 1.year.ago)
          end

          it "orders by date of affectation to the category" do
            get :index, params: index_params

            ordered_table = Nokogiri::XML(response.body).css("td").map(&:text)
            ordered_first_names = ordered_table & [user.first_name, user2.first_name]

            expect(ordered_first_names).to eq([user.first_name, user2.first_name])
          end
        end

        context "with motif_category" do
          let!(:index_params) { { department_id: department.id, motif_category_id: category_orientation.id } }

          before do
            user.rdv_contexts.first.update!(motif_category: category_orientation, created_at: 1.year.ago)
          end

          it "orders by rdv_context creation" do
            get :index, params: index_params

            ordered_table = Nokogiri::XML(response.body).css("td").map(&:text)
            ordered_first_names = ordered_table & [user.first_name, user2.first_name]

            expect(ordered_first_names).to eq([user2.first_name, user.first_name])
          end

          context "when sorting by invitations" do
            let!(:index_params) do
              {
                department_id: department.id,
                motif_category_id: category_orientation.id,
                sort_by: "invitations",
                sort_order: "desc"
              }
            end

            let!(:invitation) { create(:invitation, rdv_context: user.rdv_contexts.first, sent_at: 1.year.ago) }
            let!(:invitation2) { create(:invitation, rdv_context: user2.rdv_contexts.first, sent_at: 2.years.ago) }

            it "orders by rdv_context creation" do
              get :index, params: index_params

              ordered_table = Nokogiri::XML(response.body).css("td").map(&:text)
              ordered_first_names = ordered_table & [user.first_name, user2.first_name]

              expect(ordered_first_names).to eq([user.first_name, user2.first_name])
            end
          end
        end
      end

      context "when the agent is admin" do
        let!(:agent) { create(:agent, admin_role_in_organisations: [organisation]) }

        before do
          sign_in(agent)
        end

        it "displays the configure organisation option" do
          get :index, params: index_params

          expect(response.body).to match(/Configurer une organisation/)
        end
      end
    end

    context "when csv request" do
      before do
        allow(Exporters::GenerateUsersCsv).to receive(:call)
          .and_return(OpenStruct.new)
      end

      it "calls the service" do
        expect(Exporters::GenerateUsersCsv).to receive(:call)
        get :index, params: index_params.merge(format: :csv)
      end

      context "when not authorized" do
        let!(:another_organisation) { create(:organisation) }
        let!(:another_agent) { create(:agent, organisations: [another_organisation]) }

        before do
          sign_in(another_agent)
        end

        it "does not call the service" do
          expect do
            get :index, params: index_params.merge(format: :csv)
          end.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "when the csv creation succeeds" do
        before do
          allow(Exporters::GenerateUsersCsv).to receive(:call)
            .and_return(OpenStruct.new(success?: true))
        end

        it "is a success" do
          get :index, params: index_params.merge(format: :csv)
          expect(response).to be_successful
        end
      end
    end
  end

  describe "#edit" do
    let!(:user) { create(:user, organisations: [organisation]) }

    context "when organisation_level" do
      let!(:edit_params) { { id: user.id, organisation_id: organisation.id } }

      it "renders the edit user page" do
        get :edit, params: edit_params

        expect(response).to be_successful
        expect(response.body).to match(/Modifier usager/)
      end
    end

    context "when department_level" do
      let!(:edit_params) { { id: user.id, department_id: department.id } }

      it "renders the edit user page" do
        get :edit, params: edit_params

        expect(response).to be_successful
        expect(response.body).to match(/Modifier usager/)
      end
    end
  end

  describe "#update" do
    let!(:user) { create(:user, organisations: [organisation]) }
    let!(:update_params) do
      { id: user.id, organisation_id: organisation.id, user: { birth_date: "20/12/1988" } }
    end

    before do
      sign_in(agent)
    end

    context "when json request" do
      let(:update_params) do
        {
          user: {
            birth_date: "20/12/1988"
          },
          id: user.id,
          organisation_id: organisation.id,
          format: "json"
        }
      end

      before do
        allow(Users::Save).to receive(:call)
          .and_return(OpenStruct.new)
      end

      it "calls the service" do
        expect(Users::Save).to receive(:call)
        post :update, params: update_params
      end

      context "when not authorized" do
        let!(:another_organisation) { create(:organisation) }
        let!(:another_agent) { create(:agent, organisations: [another_organisation]) }

        before do
          sign_in(another_agent)
        end

        it "does not call the service" do
          expect do
            post :update, params: update_params
          end.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "when the update succeeds" do
        before do
          allow(Users::Save).to receive(:call)
            .and_return(OpenStruct.new(success?: true, user: user))
        end

        it "is a success" do
          post :update, params: update_params
          expect(response).to be_successful
          expect(response.parsed_body["success"]).to eq(true)
        end
      end

      context "with tags" do
        let(:tag) { create(:tag) }
        let(:update_params) do
          {
            user: {
              tag_users_attributes: [{ tag_id: tag.id }]
            },
            id: user.id,
            organisation_id: organisation.id,
            format: "json"
          }
        end
        let!(:existing_tag) { create(:tag, value: "lol") }

        before do
          allow(Users::Save).to receive(:call).and_call_original
          allow_any_instance_of(Users::Save).to receive(:upsert_rdv_solidarites_user)
            .and_return true
          allow_any_instance_of(Users::Save).to receive(:assign_rdv_solidarites_user_id)
            .and_return true
          organisation.tags << tag
          organisation.tags << existing_tag
          user.tags << existing_tag
        end

        it "updates the tags" do
          post :update, params: update_params
          expect(user.reload.tags.size).to eq(1)
          expect(user.reload.tags.first.id).to eq(tag.id)
        end

        context "with empty tags" do
          let(:update_params) do
            {
              user: {
                birth_date: "20/12/1988",
                tag_users_attributes: []
              },
              id: user.id,
              organisation_id: organisation.id,
              format: "json"
            }
          end

          before do
            # This is unfortunately required because without it Rspec removes all params
            # that return false to .present? and tag_users_attributes
            # being an empty array, the controller doesn't receive it
            allow_any_instance_of(described_class).to receive(:params).and_return(
              ActionController::Parameters.new(update_params)
            )
          end

          it "removes all existing tags" do
            post :update, params: update_params
            expect(user.reload.tags.size).to eq(0)
          end
        end

        context "without tags given" do
          let(:update_params) do
            {
              user: {
                birth_date: "20/12/1988",
                tag_users_attributes: nil
              },
              id: user.id,
              organisation_id: organisation.id,
              format: "json"
            }
          end

          before do
            allow_any_instance_of(described_class).to receive(:params).and_return(
              ActionController::Parameters.new(update_params)
            )
          end

          it "does not remove existing tags" do
            post :update, params: update_params
            expect(user.reload.tags.first).to eq(existing_tag)
          end
        end
      end

      context "when the creation fails" do
        before do
          allow(Users::Save).to receive(:call)
            .and_return(OpenStruct.new(success?: false, errors: ["some error"]))
        end

        it "is not a success" do
          post :update, params: update_params
          expect(response).not_to be_successful
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body["success"]).to eq(false)
        end

        it "renders the errors" do
          post :update, params: update_params
          expect(response).not_to be_successful
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body["errors"]).to eq(["some error"])
        end
      end
    end

    context "when html request" do
      let!(:update_params) do
        { id: user.id, organisation_id: organisation.id,
          user: { first_name: "Alain", last_name: "Deloin", phone_number: "0123456789" } }
      end

      before do
        sign_in(agent)
        allow(Users::Save).to receive(:call)
          .and_return(OpenStruct.new(success?: true))
      end

      it "calls the service" do
        expect(Users::Save).to receive(:call)
          .with(
            user: user,
            organisation: organisation,
            rdv_solidarites_session: rdv_solidarites_session
          )
        patch :update, params: update_params
      end

      context "when not authorized" do
        let!(:another_organisation) { create(:organisation) }
        let!(:another_agent) { create(:agent, organisations: [another_organisation]) }

        before do
          sign_in(another_agent)
        end

        it "does not call the service" do
          expect do
            patch :update, params: update_params
          end.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "when the update succeeds" do
        context "when organisation level" do
          it "redirects to the show page" do
            patch :update, params: update_params
            expect(response).to redirect_to(organisation_user_path(organisation, user))
          end
        end

        context "when department level" do
          let!(:update_params) do
            { id: user.id, department_id: department.id,
              user: { first_name: "Alain", last_name: "Deloin", phone_number: "0123456789" } }
          end

          it "redirects to the show page" do
            patch :update, params: update_params
            expect(response).to redirect_to(department_user_path(department, user))
          end
        end
      end

      context "when the creation fails" do
        before do
          allow(Users::Save).to receive(:call)
            .and_return(OpenStruct.new(success?: false, errors: ["some error"]))
        end

        it "renders the edit page" do
          patch :update, params: update_params
          expect(response).not_to be_successful
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end
end
