describe Creneaux::StoreAllNumberOfCreneauxAvailableJob do
  subject { described_class.new.perform }

  let!(:organisation_with_oauth_agent) do
    create(:organisation, agents: [create(:agent, :with_rdv_solidarites_oauth_token)])
  end
  let!(:category_configuration) { create(:category_configuration, organisation: organisation_with_oauth_agent) }
  let!(:category_configuration_with_referents) do
    create(:category_configuration, organisation: organisation_with_oauth_agent, rdv_with_referents: true)
  end
  let!(:category_configuration_without_oauth_agent) do
    create(:category_configuration, organisation: create(:organisation, agents: [create(:agent)]))
  end

  before { allow(Creneaux::StoreNumberOfCreneauxAvailableJob).to receive(:perform_later) }

  it "enqueues a job only for the configurations without referents of organisations having an oauth agent" do
    subject
    expect(Creneaux::StoreNumberOfCreneauxAvailableJob).to have_received(:perform_later).once
    expect(Creneaux::StoreNumberOfCreneauxAvailableJob).to have_received(:perform_later).with(category_configuration.id)
  end
end
