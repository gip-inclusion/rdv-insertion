describe ImportUserAssociationsFromRdvSolidaritesJob do
  subject { described_class.new.perform(user.id) }

  let!(:organisation) { create(:organisation) }
  let!(:user) { create(:user, organisations: [organisation]) }
  let!(:agent_without_oauth_token) { create(:agent, organisations: [organisation]) }

  before do
    allow(Users::ImportAssociationsFromRdvSolidarites).to receive(:call).and_return(OpenStruct.new(success?: true))
  end

  context "when an agent of the user organisations has an oauth token" do
    let!(:agent_with_oauth_token) do
      create(:agent, :with_rdv_solidarites_oauth_token, organisations: [organisation])
    end

    it "imports the associations as this agent" do
      expect(Users::ImportAssociationsFromRdvSolidarites).to receive(:call).with(user:) do
        expect(Current.agent).to eq(agent_with_oauth_token)
        OpenStruct.new(success?: true)
      end
      subject
    end
  end

  context "when no agent of the user organisations has an oauth token" do
    it "does not import the associations" do
      subject
      expect(Users::ImportAssociationsFromRdvSolidarites).not_to have_received(:call)
    end
  end
end
