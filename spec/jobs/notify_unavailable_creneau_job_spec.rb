describe NotifyUnavailableCreneauJob do
  subject do
    described_class.new.perform(organisation_id)
  end

  let!(:organisation) { create(:organisation) }
  let!(:organisation_id) { organisation.id }
  let!(:organisation_mail) { instance_double("organisation_mail") }

  let!(:unavailable_params_motifs) do
    [
      {
        motif_category_name: "RSA Orientation",
        city_code: %w[75001 75002 75003],
        referent_ids: ["1"],
        invations_counter: 3
      },
      {
        motif_category_name: "RSA Accompagnement",
        city_code: ["75004"],
        referent_ids: [],
        invations_counter: 1
      }
    ]
  end

  before do
    allow(Invitations::VerifyOrganisationCreneauxAvailability).to receive(:call)
      .and_return(OpenStruct.new(success?: true, unavailable_params_motifs: unavailable_params_motifs))
    allow(OrganisationMailer).to receive(:creneau_unavailable).and_return(organisation_mail)
    allow(organisation_mail).to receive(:deliver_now)
  end

  it "send the email" do
    expect(OrganisationMailer).to receive(:creneau_unavailable)
      .with(organisation: organisation, motifs: unavailable_params_motifs)
    expect(organisation_mail).to receive(:deliver_now)
    subject
  end

  it "send the message to mattermost" do
    expect(MattermostClient).to receive(:send_to_notif_channel)
      .with(
        "Créneaux indisponibles pour l'organisation #{organisation.name}" \
        " (Département: #{organisation.department.name})\n" \
        " Motif : #{unavailable_params_motifs[0][:motif_category_name]}\n" \
        " Nombre d'invitations concernées : #{unavailable_params_motifs[0][:invations_counter]}\n" \
        " Référents (rdvsp_ids) : #{unavailable_params_motifs[0][:referent_ids].join(', ')}\n" \
      )
    expect(MattermostClient).to receive(:send_to_notif_channel)
      .with(
        "Créneaux indisponibles pour l'organisation #{organisation.name}" \
        " (Département: #{organisation.department.name})\n" \
        " Motif : #{unavailable_params_motifs[1][:motif_category_name]}\n" \
        " Nombre d'invitations concernées : #{unavailable_params_motifs[1][:invations_counter]}\n" \
      )
    subject
  end
end
