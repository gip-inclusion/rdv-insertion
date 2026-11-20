describe Creneaux::RetrieveAndNotifyAllUnavailableCreneauxJob do
  subject { described_class.new.perform }

  let!(:organisation_with_oauth_agent) do
    create(:organisation, agents: [create(:agent, :with_rdv_solidarites_oauth_token)])
  end
  let!(:other_organisation_with_oauth_agent) do
    create(:organisation, agents: [create(:agent, :with_rdv_solidarites_oauth_token)])
  end
  let!(:organisation_without_oauth_agent) { create(:organisation, agents: [create(:agent)]) }
  let!(:organisation_without_agent) { create(:organisation) }

  before { allow(Creneaux::RetrieveAndNotifyUnavailableCreneauxJob).to receive(:perform_later) }

  it "enqueues a job for each organisation having an agent with an oauth token" do
    subject
    expect(Creneaux::RetrieveAndNotifyUnavailableCreneauxJob)
      .to have_received(:perform_later).with(organisation_with_oauth_agent.id)
    expect(Creneaux::RetrieveAndNotifyUnavailableCreneauxJob)
      .to have_received(:perform_later).with(other_organisation_with_oauth_agent.id)
  end

  it "skips the organisations without an agent with an oauth token" do
    subject
    expect(Creneaux::RetrieveAndNotifyUnavailableCreneauxJob)
      .not_to have_received(:perform_later).with(organisation_without_oauth_agent.id)
    expect(Creneaux::RetrieveAndNotifyUnavailableCreneauxJob)
      .not_to have_received(:perform_later).with(organisation_without_agent.id)
  end
end
