describe DeduplicateRdvSolidaritesWebhooksFromRetrySetJob do
  subject { described_class.new.perform(class_name, resource_id) }

  let(:class_name) { "InboundWebhooks::RdvSolidarites::ProcessRdvJob" }
  let(:resource_id) { 123 }
  let(:older_sidekiq_job_from_same_class_and_resource_id) do
    instance_double(
      Sidekiq::JobRecord,
      display_class: class_name,
      display_args: [{ "id" => resource_id }, { "timestamp" => "2024-05-01T12:00:00Z" }],
      jid: SecureRandom.uuid
    )
  end
  let(:newer_sidekiq_job_from_same_class_and_resource_id) do
    instance_double(
      Sidekiq::JobRecord,
      display_class: class_name,
      display_args: [{ "id" => resource_id }, { "timestamp" => "2024-05-01T12:00:01Z" }],
      jid: SecureRandom.uuid
    )
  end
  let(:sidekiq_job_from_same_class_and_different_resource_id) do
    instance_double(
      Sidekiq::JobRecord,
      display_class: class_name,
      display_args: [{ "id" => 456 }, { "timestamp" => "2024-05-01T12:00:00Z" }],
      jid: SecureRandom.uuid
    )
  end
  let(:sidekiq_job_from_other_class) do
    instance_double(
      Sidekiq::JobRecord,
      display_class: "SomeOtherJob",
      jid: SecureRandom.uuid
    )
  end

  before do
    allow(Sidekiq::RetrySet).to receive(:new).and_return(
      [
        older_sidekiq_job_from_same_class_and_resource_id,
        sidekiq_job_from_same_class_and_different_resource_id,
        sidekiq_job_from_other_class,
        newer_sidekiq_job_from_same_class_and_resource_id
      ]
    )
  end

  describe "#perform" do
    it "deduplicates the webhooks" do
      expect(older_sidekiq_job_from_same_class_and_resource_id).to receive(:delete)
      expect(newer_sidekiq_job_from_same_class_and_resource_id).not_to receive(:delete)
      expect(sidekiq_job_from_same_class_and_different_resource_id).not_to receive(:delete)
      expect(sidekiq_job_from_other_class).not_to receive(:delete)

      subject
    end
  end
end
