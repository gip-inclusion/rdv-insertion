describe NotifyRdvChangesToExternalOrganisationEmailJob do
  subject do
    described_class.new.perform([participation_id], participation.rdv.id, event)
  end

  let!(:organisation) { create(:organisation) }
  let!(:category_configuration) do
    create(:category_configuration, organisation:, email_to_notify_rdv_changes: "test@test.com", motif_category:)
  end
  let!(:motif_category) { create(:motif_category) }
  let!(:follow_up) { create(:follow_up, motif_category:) }
  let!(:participation) { create(:participation, organisation:, follow_up:) }
  let!(:rdv) do
    create(
      :rdv,
      organisation:,
      address: "some place",
      starts_at: 2.days.from_now,
      participations: [participation]
    )
  end
  let!(:participation_id) { participation.id }

  let!(:event) { "created" }
  let!(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }
  let!(:cache) { Rails.cache }

  before do
    allow(Rails).to receive(:cache).and_return(memory_store)
    Rails.cache.clear
  end

  describe "#perform" do
    context "category_configuration does not notify_rdv_changes" do
      let!(:category_configuration) do
        create(:category_configuration, organisation:, email_to_notify_rdv_changes: nil, motif_category:)
      end

      it "does not send the notification" do
        expect(OrganisationMailer).not_to receive(:notify_rdv_changes)
        subject
      end
    end

    context "already notified" do
      it "does not send the notification" do
        expect(OrganisationMailer).to receive(:notify_rdv_changes).once.and_return(OpenStruct.new(deliver_now: nil))
        2.times { described_class.new.perform([participation_id], rdv.id, event) }

        travel 3.hours # cache expires after 1 hour
        expect(OrganisationMailer).to receive(:notify_rdv_changes).once.and_return(OpenStruct.new(deliver_now: nil))
        2.times { described_class.new.perform([participation_id], rdv.id, event) }
      end
    end

    context "not notified" do
      it "sends the notification" do
        expect(OrganisationMailer).to receive(:notify_rdv_changes)
          .once
          .with(
            to: category_configuration.email_to_notify_rdv_changes,
            participations: [participation],
            rdv: rdv,
            event: event
          ).and_return(OpenStruct.new(deliver_now: nil))
        subject
      end
    end
  end
end
