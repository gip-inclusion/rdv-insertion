describe AgentsApplicantsController, type: :controller do
  let!(:applicant_id) { 2222 }
  let!(:applicant) do
    create(:applicant, id: applicant_id, organisations: [organisation1, organisation2], department: department)
  end
  let!(:organisation1) { create(:organisation, name: "CD de DIE") }
  let!(:organisation2) { create(:organisation, name: "CD de Valence") }
  let!(:organisation3) { create(:organisation) }
  let!(:department) { create(:department, organisations: [organisation1, organisation2, organisation3]) }
  let!(:agent1) do
    create(
      :agent,
      organisations: [organisation1], first_name: "Bernard", last_name: "Lama", email: "bernardlama@france98.fr"
    )
  end
  let!(:agent2) do
    create(
      :agent,
      organisations: [organisation2], first_name: "Lionel", last_name: "Charbonnier",
      email: "lionelcharbonnier@france98.fr"
    )
  end
  let!(:agent3) do
    create(
      :agent,
      organisations: [organisation3], first_name: "Fabien", last_name: "Barthez"
    )
  end

  let!(:agent) { create(:agent, organisations: [organisation1]) }

  render_views

  before do
    sign_in(agent)
  end

  describe "#new" do
    it "shows the agents selection" do
      get :new, params: { applicant_id: applicant_id, department_id: department.id }

      expect(response).to be_successful
      expect(response.body).to match(/Bernard Lama \(bernardlama@france98.fr\)/)
      expect(response.body).to match(/Lionel Charbonnier \(lionelcharbonnier@france98.fr\)/)
      expect(response.body).not_to match(/Fabien Barthez/)
    end
  end

  describe "#create" do
    subject do
      post :create, params: {
        applicant_id: applicant_id, department_id: department.id, agents_applicant: {
          agent_id: agent2.id
        }, format: "turbo_stream"
      }
    end

    it "assigns the agent with a success message" do
      subject

      expect(response).to be_successful
      expect(applicant.reload.agents).to eq([agent2])
      expect(response.body).to match(/flashes/)
      expect(response.body).to match(/Le référent a bien été assigné/)
    end
  end
end
