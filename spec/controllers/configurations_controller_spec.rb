describe ConfigurationsController do
  let!(:organisation) { create(:organisation) }
  let!(:agent) { create(:agent, admin_role_in_organisations: [organisation]) }

  render_views

  before do
    sign_in(agent)
  end

  describe "#show" do
    it "renders the configuration page" do
      get :show, params: { organisation_id: organisation.id }

      expect(response).to be_successful
      expect(response.body).to match(/Détails de l'organisation/)
      expect(response.body).to match(/Catégories de motifs configurés/)
      expect(response.body).to match(/Configuration des messages/)
      expect(response.body).to match(/Agents de l'organisation/)
      expect(response.body).to match(/Gestion des tags associés/)
      expect(response.body).to match(/Gestion des autorisations/)
    end
  end
end