describe CreneauOpeningRequests::CreateMany, type: :service do
  subject do
    described_class.call(
      user_list_upload: user_list_upload,
      recipient_agent_ids: recipient_agent_ids,
      available_creneaux_count: 26,
      users_to_invite_count: 28
    )
  end

  let!(:department) { create(:department) }
  let!(:organisation) { create(:organisation, department: department, rdv_solidarites_organisation_id: 42) }
  let!(:user_list_upload) { create(:user_list_upload, structure: organisation) }
  let!(:agent_a) { create(:agent, organisations: [organisation]) }
  let!(:agent_b) { create(:agent, organisations: [organisation]) }
  let(:recipient_agent_ids) { [agent_a.id, agent_b.id] }

  it "is a success" do
    expect(subject).to be_success
  end

  it "creates one CreneauOpeningRequest per recipient" do
    expect { subject }.to change(CreneauOpeningRequest, :count).by(2)
  end

  it "enqueues a send-email job per created request" do
    expect { subject }.to have_enqueued_job(CreneauOpeningRequests::SendEmailJob).twice
  end

  it "snapshots the counts on each request" do
    subject

    expect(CreneauOpeningRequest.pluck(:users_to_invite_count, :available_creneaux_count))
      .to all(eq([28, 26]))
  end

  it "exposes the created requests in the result" do
    expect(subject.creneau_opening_requests.map(&:recipient_agent_id))
      .to contain_exactly(agent_a.id, agent_b.id)
  end

  context "when the upload structure is an organisation" do
    it "stores the planning plage_ouvertures URL as link" do
      subject

      expect(CreneauOpeningRequest.last.link).to end_with(
        "/admin/organisations/42/planning/plage_ouvertures"
      )
    end
  end

  context "when the upload structure is a department" do
    let!(:user_list_upload) { create(:user_list_upload, structure: department) }

    it "stores the RDV-Solidarités root URL as link" do
      subject

      expect(CreneauOpeningRequest.last.link).to eq(ENV.fetch("RDV_SOLIDARITES_URL"))
    end
  end

  context "when recipient_agent_ids is empty" do
    let(:recipient_agent_ids) { [] }

    it "is a failure" do
      expect(subject).to be_failure
    end

    it "returns a meaningful error" do
      expect(subject.errors).to include(/destinataire/i)
    end

    it "does not create any CreneauOpeningRequest" do
      expect { subject }.not_to change(CreneauOpeningRequest, :count)
    end
  end
end
