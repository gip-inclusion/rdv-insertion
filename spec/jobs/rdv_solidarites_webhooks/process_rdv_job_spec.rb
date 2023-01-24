describe RdvSolidaritesWebhooks::ProcessRdvJob do
  subject do
    described_class.new.perform(data, meta)
  end

  let!(:user_id1) { 442 }
  let!(:user_id2) { 443 }
  let!(:user_ids) { [user_id1, user_id2] }
  let!(:rdv_solidarites_rdv_id) { 22 }
  let!(:rdv_solidarites_organisation_id) { 52 }
  let!(:rdv_solidarites_lieu_id) { 43 }
  let!(:rdv_solidarites_motif_id) { 53 }
  let!(:participations_attributes) do
    [
      { id: 998, status: "unknown", user: { id: user_id1 } },
      { id: 999, status: "unknown", user: { id: user_id2 } }
    ]
  end
  let!(:lieu_attributes) { { id: rdv_solidarites_lieu_id, name: "DINUM", address: "20 avenue de Ségur" } }
  let!(:motif_attributes) do
    { id: 53, location_type: "public_office", category: "rsa_orientation", name: "RSA orientation" }
  end
  let!(:users) { [{ id: user_id1 }, { id: user_id2 }] }
  let!(:starts_at) { "2021-09-08 12:00:00 UTC" }
  let!(:data) do
    {
      "id" => rdv_solidarites_rdv_id,
      "starts_at" => starts_at,
      "address" => "20 avenue de segur",
      "context" => "all good",
      "lieu" => lieu_attributes,
      "motif" => motif_attributes,
      "users" => users,
      "rdvs_users" => participations_attributes,
      "organisation" => { id: rdv_solidarites_organisation_id }
    }.deep_symbolize_keys
  end

  let!(:timestamp) { "2021-05-30 14:44:22 +0200" }
  let!(:meta) do
    {
      "model" => "Rdv",
      "event" => "created",
      "timestamp" => timestamp
    }.deep_symbolize_keys
  end

  let!(:applicant) { create(:applicant, organisations: [organisation], id: 3, rdv_solidarites_user_id: 442) }
  let!(:applicant2) { create(:applicant, organisations: [organisation], id: 4, rdv_solidarites_user_id: 443) }
  let!(:applicants) { Applicant.where(id: [applicant.id, applicant2.id]) }

  let!(:configuration) { create(:configuration, convene_applicant: false, motif_category: "rsa_orientation") }
  let!(:organisation) do
    create(
      :organisation,
      rdv_solidarites_organisation_id: rdv_solidarites_organisation_id, configurations: [configuration]
    )
  end
  let!(:motif) { create(:motif, rdv_solidarites_motif_id: rdv_solidarites_motif_id) }
  let!(:lieu) do
    create(
      :lieu, rdv_solidarites_lieu_id: rdv_solidarites_lieu_id, name: "DINUM", address: "20 avenue de Ségur",
             organisation: organisation
    )
  end

  let!(:invitation) do
    create(
      :invitation,
      organisations: [organisation],
      rdv_context: rdv_context,
      sent_at: 2.days.ago,
      valid_until: 3.days.from_now
    )
  end

  let!(:invitation2) do
    create(
      :invitation,
      organisations:
      [organisation],
      rdv_context: rdv_context2,
      sent_at: 2.days.ago,
      valid_until: 3.days.from_now
    )
  end

  let!(:invitation3) do
    create(
      :invitation,
      organisations: [organisation],
      rdv_context: rdv_context,
      sent_at: 4.days.ago,
      valid_until: 3.days.ago
    )
  end

  let!(:rdv_context) do
    build(:rdv_context, motif_category: "rsa_orientation", applicant: applicant)
  end

  let!(:rdv_context2) do
    build(:rdv_context, motif_category: "rsa_orientation", applicant: applicant2)
  end

  describe "#perform" do
    before do
      allow(RdvContext).to receive(:find_or_create_by!)
        .with(applicant: applicant, motif_category: "rsa_orientation")
        .and_return(rdv_context)
      allow(RdvContext).to receive(:find_or_create_by!)
        .with(applicant: applicant2, motif_category: "rsa_orientation")
        .and_return(rdv_context2)
      allow(UpsertRecordJob).to receive(:perform_async)
      allow(InvalidateInvitationJob).to receive(:perform_async)
      allow(DeleteRdvJob).to receive(:perform_async)
      allow(SendRdvSolidaritesWebhookJob).to receive(:perform_async)
      allow(MattermostClient).to receive(:send_to_notif_channel)
    end

    context "when no organisation is found" do
      let!(:organisation) { create(:organisation, rdv_solidarites_organisation_id: "random-orga-id") }

      it "raises an error" do
        expect { subject }.to raise_error(WebhookProcessingJobError, "Organisation not found with id 52")
      end
    end

    context "when no motif is found" do
      let!(:motif) { create(:motif, rdv_solidarites_motif_id: "random-motif-id") }

      it "raises an error" do
        expect { subject }.to raise_error(WebhookProcessingJobError, "Motif not found with id 53")
      end
    end

    context "when no applicant is found" do
      before do
        allow(Applicant).to receive(:where)
          .with(rdv_solidarites_user_id: user_ids)
          .and_return([])
      end

      it "does not call the other jobs" do
        [UpsertRecordJob, DeleteRdvJob, InvalidateInvitationJob].each do |klass|
          expect(klass).not_to receive(:perform_async)
        end
        subject
      end
    end

    describe "upserting the rdv" do
      context "it upserts the rdv (for a create)" do
        it "enqueues a job to upsert the rdv" do
          expect(UpsertRecordJob).to receive(:perform_async)
            .with(
              "Rdv",
              data,
              {
                participations_attributes: [
                  {
                    id: nil,
                    status: "unknown",
                    applicant_id: 3,
                    rdv_solidarites_participation_id: 998,
                    rdv_context_id: rdv_context.id
                  },
                  {
                    id: nil,
                    status: "unknown",
                    applicant_id: 4,
                    rdv_solidarites_participation_id: 999,
                    rdv_context_id: rdv_context2.id
                  }
                ],
                organisation_id: organisation.id,
                motif_id: motif.id,
                lieu_id: lieu.id,
                last_webhook_update_received_at: timestamp
              }
            )

          subject
        end

        it "enqueues jobs to invalidate the related sent valid invitations" do
          expect(InvalidateInvitationJob).to receive(:perform_async).exactly(1).time.with(invitation.id)
          expect(InvalidateInvitationJob).to receive(:perform_async).exactly(1).time.with(invitation2.id)
          expect(InvalidateInvitationJob).not_to receive(:perform_async).with(invitation3.id)
          subject
        end
      end

      context "it upserts the rdv (for a participation update and destroy)" do
        let!(:participations_attributes) do
          [{ id: 999, status: "seen", user: { id: user_id2 } }]
        end
        let!(:users) { [{ id: user_id2 }] }

        # Rdv create factory create a new applicant (and participation) by default
        let!(:rdv) { create(:rdv, rdv_solidarites_rdv_id: rdv_solidarites_rdv_id, organisation: organisation) }
        let!(:default_applicant) { rdv.applicants.first }
        let!(:default_participation) { rdv.participations.first }
        let!(:participation2) do
          create(
            :participation,
            applicant: applicant2,
            rdv: rdv,
            status: "unknown",
            id: 2,
            rdv_solidarites_participation_id: 999
          )
        end
        let!(:participations_attributes_expected) do
          [
            {
              id: 2,
              status: "seen",
              applicant_id: 4,
              rdv_solidarites_participation_id: 999,
              rdv_context_id: rdv_context2.id
            },
            {
              _destroy: true,
              applicant_id: default_applicant.id,
              id: default_participation.id
            }
          ]
        end

        it "enqueues a job to upsert the rdv with updated status and destroyed participation" do
          expect(UpsertRecordJob).to receive(:perform_async)
            .with(
              "Rdv",
              data,
              {
                participations_attributes: participations_attributes_expected,
                organisation_id: organisation.id,
                motif_id: motif.id,
                lieu_id: lieu.id,
                last_webhook_update_received_at: timestamp
              }
            )

          subject
        end
      end
    end

    context "when it is a destroy event" do
      let!(:meta) { { "model" => "Rdv", "event" => "destroyed" }.deep_symbolize_keys }

      it "enqueues a delete job" do
        expect(DeleteRdvJob).to receive(:perform_async)
          .with(rdv_solidarites_rdv_id)
        subject
      end
    end

    context "for a convocation" do
      let!(:motif_attributes) do
        { id: 53, location_type: "public_office", category: "rsa_orientation", name: "RSA orientation: Convocation" }
      end
      let!(:configuration) { create(:configuration, convene_applicant: true, motif_category: "rsa_orientation") }

      it "sets the convocable attribute when upserting the rdv" do
        expect(UpsertRecordJob).to receive(:perform_async)
          .with(
            "Rdv",
            data,
            {
              participations_attributes: [
                {
                  id: nil,
                  status: "unknown",
                  applicant_id: 3,
                  rdv_solidarites_participation_id: 998,
                  rdv_context_id: rdv_context.id
                },
                {
                  id: nil,
                  status: "unknown",
                  applicant_id: 4,
                  rdv_solidarites_participation_id: 999,
                  rdv_context_id: rdv_context2.id
                }
              ],
              organisation_id: organisation.id,
              motif_id: motif.id,
              lieu_id: lieu.id,
              convocable: true,
              last_webhook_update_received_at: timestamp
            }
          )
        subject
      end

      context "when the lieu in the webhook is not sync with the one in db" do
        context "when no lieu attrributes is in the webhook" do
          let!(:lieu_attributes) { nil }

          it "raises an error" do
            expect { subject }.to raise_error(WebhookProcessingJobError, "Lieu in webhook is not coherent. ")
          end
        end

        context "when the attributes in the webhooks do not match the ones in db" do
          let!(:lieu_attributes) { { id: rdv_solidarites_lieu_id, name: "DITP", address: "7 avenue de Ségur" } }

          it "raises an error" do
            expect { subject }.to raise_error(
              WebhookProcessingJobError, "Lieu in webhook is not coherent. #{lieu_attributes}"
            )
          end
        end
      end
    end

    context "with an invalid category" do
      let!(:motif_attributes) { { id: 53, location_type: "public_office", category: nil } }

      it "does not call any job" do
        [UpsertRecordJob, DeleteRdvJob].each do |klass|
          expect(klass).not_to receive(:perform_async)
        end
        subject
      end
    end

    context "with no matching configuration" do
      let!(:motif_attributes) { { id: 53, location_type: "public_office", category: "rsa_accompagnement" } }

      it "does not call any job" do
        [UpsertRecordJob, DeleteRdvJob].each do |klass|
          expect(klass).not_to receive(:perform_async)
        end
        subject
      end
    end

    context "when there are webhook endpoints associated to the org" do
      let!(:webhook_endpoint) do
        create(:webhook_endpoint, organisations: [organisation])
      end
      let!(:department_internal_id) { "some-dept-id" }
      let!(:applicant) do
        create(
          :applicant,
          organisations: [organisation],
          title: "monsieur",
          rdv_solidarites_user_id: user_id1,
          department_internal_id: department_internal_id
        )
      end

      let!(:webhook_payload) do
        {
          data: data.merge(
            users: [
              { id: user_id1, department_internal_id: department_internal_id, title: "monsieur" },
              { id: user_id2, department_internal_id: nil, title: "monsieur" }
            ]
          ),
          meta: meta
        }
      end

      it "enqueues a webhook job with an augmented payload" do
        expect(SendRdvSolidaritesWebhookJob).to receive(:perform_async)
          .with(webhook_endpoint.id, webhook_payload)
        subject
      end
    end
  end
end
