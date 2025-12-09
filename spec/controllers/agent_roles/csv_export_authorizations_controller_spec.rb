describe AgentRoles::CsvExportAuthorizationsController do
  let!(:department) { create(:department) }
  let!(:organisation) { create(:organisation, department:) }
  let!(:other_organisation) { create(:organisation, department:) }
  let!(:admin) { create(:agent, admin_role_in_organisations: [organisation]) }
  let!(:basic_agent) { create(:agent, basic_role_in_organisations: [organisation, other_organisation]) }
  let!(:agent_role_for_organisation) { organisation.agent_roles.find { |ar| ar.agent_id == basic_agent.id } }
  let!(:agent_role_from_other_org) { other_organisation.agent_roles.find { |ar| ar.agent_id == basic_agent.id } }

  render_views

  describe "#batch_update" do
    let(:batch_update_params) do
      {
        organisation_id: organisation.id,
        csv_export_authorizations: {
          organisation_id: organisation.id,
          agent_role_ids: [agent_role_for_organisation.id]
        }
      }
    end

    context "when agent is not admin of the organisation" do
      let!(:non_admin_agent) { create(:agent, basic_role_in_organisations: [organisation]) }

      before do
        sign_in(non_admin_agent)
      end

      it "prevents the update and redirects with error" do
        expect do
          post :batch_update, params: batch_update_params
        end.not_to change(agent_role_for_organisation, :authorized_to_export_csv)

        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to be_present
      end
    end

    context "when agent is admin of the organisation" do
      before do
        sign_in(admin)
      end

      it "allows the update" do
        expect do
          post :batch_update, params: batch_update_params
        end.to change { agent_role_for_organisation.reload.authorized_to_export_csv }.from(false).to(true)

        expect(response).to redirect_to(organisation_configuration_agents_path(organisation))
        expect(flash[:success]).to eq("Les autorisations ont bien été mises à jour")
      end

      context "when trying to authorize agent roles from other organisations" do
        it "prevents authorizing agent roles from other organisations" do
          post :batch_update, params: {
            organisation_id: organisation.id,
            csv_export_authorizations: {
              organisation_id: organisation.id,
              agent_role_ids: [agent_role_from_other_org.id]
            }
          }

          expect(agent_role_from_other_org.reload.authorized_to_export_csv).to be false
        end

        it "only processes agent roles that belong to the organisation" do
          post :batch_update, params: {
            organisation_id: organisation.id,
            csv_export_authorizations: {
              organisation_id: organisation.id,
              agent_role_ids: [agent_role_for_organisation.id, agent_role_from_other_org.id]
            }
          }

          expect(agent_role_for_organisation.reload.authorized_to_export_csv).to be true
          expect(agent_role_from_other_org.reload.authorized_to_export_csv).to be false
        end
      end
    end
  end
end
