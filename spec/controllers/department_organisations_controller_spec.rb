describe DepartmentOrganisationsController do
  let!(:organisation1) { create(:organisation, name: "Marseille") }
  let!(:organisation2) { create(:organisation, name: "Aix-en-Provence") }
  let!(:organisation3) { create(:organisation, name: "Montpellier") }
  let!(:department) { create(:department, organisations: [organisation1, organisation2]) }
  let!(:agent) do
    create(:agent, admin_role_in_organisations: [organisation1, organisation3],
                   basic_role_in_organisations: [organisation2])
  end

  render_views

  before do
    sign_in(agent)
  end

  describe "#index" do
    it "displays the organisations from the department where the agent is admin" do
      get :index, params: { department_id: department.id }

      expect(response).to be_successful
      expect(response.body).to have_link("Marseille", href: organisation_configuration_informations_path(organisation1))
      expect(response.body).to have_no_link("Aix-en-Provence", href: organisation_configuration_informations_path(organisation2))
      expect(response.body).to have_no_link("Montpellier", href: organisation_configuration_informations_path(organisation3))
    end
  end
end
