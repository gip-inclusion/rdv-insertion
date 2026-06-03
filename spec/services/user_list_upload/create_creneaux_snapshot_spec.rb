describe UserListUpload::CreateCreneauxSnapshot, type: :service do
  subject { described_class.call(user_list_upload:) }

  let!(:organisation) { create(:organisation, rdv_solidarites_organisation_id: 3234) }
  let!(:agent) { create(:agent, admin_role_in_organisations: [organisation]) }
  let!(:category_configuration) { create(:category_configuration, organisation:) }
  let!(:user_list_upload) do
    create(:user_list_upload, agent:, category_configuration:, structure: organisation)
  end

  context "when the API call succeeds" do
    before do
      allow(RdvSolidaritesApi::RetrieveCreneauAvailability).to receive(:call).and_return(
        OpenStruct.new(success?: true, creneau_availability_count: 8)
      )
    end

    it "succeeds" do
      expect(subject.success?).to be(true)
    end

    it "creates a snapshot with the retrieved number of créneaux" do
      expect { subject }.to change(UserListUpload::CreneauxSnapshot, :count).by(1)

      snapshot = user_list_upload.reload.creneaux_snapshot
      expect(snapshot.number_of_creneaux_available).to eq(8)
    end

    it "requests the availability for all the upload organisations" do
      subject

      expect(RdvSolidaritesApi::RetrieveCreneauAvailability).to have_received(:call).with(
        link_params: {
          motif_category_short_name: category_configuration.motif_category_short_name,
          organisation_ids: [organisation.rdv_solidarites_organisation_id]
        },
        total_count: true
      )
    end
  end

  context "when the API call fails" do
    before do
      allow(RdvSolidaritesApi::RetrieveCreneauAvailability).to receive(:call).and_return(
        OpenStruct.new(success?: false, errors: ["RDV-S indisponible"])
      )
    end

    it "fails and does not create a snapshot" do
      expect(subject.success?).to be(false)
      expect(UserListUpload::CreneauxSnapshot.count).to eq(0)
    end
  end
end
