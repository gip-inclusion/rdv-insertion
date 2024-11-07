RSpec.describe Sidekiq::ArgumentsFilter do
  describe ".filter_arguments!" do
    let(:job_args) do
      [
        { "id" => 22, "email" => "user@example.com", "name" => "John Doe", "timestamp" => "2024-10-07T12:34:56Z" },
        { "organisation_id" => 23, "password" => "secret", "created_at" => "2024-10-07T12:34:56Z" },
        ["public_data", { "phone_number" => "123-456-7890" }]
      ]
    end

    it "filters sensitive data and does not filter non-sensitive data" do
      described_class.filter_arguments!(job_args)
      expect(job_args).to eq([
                               { "id" => 22, "email" => "[FILTERED]", "name" => "[FILTERED]",
                                 "timestamp" => "2024-10-07T12:34:56Z" },
                               { "organisation_id" => 23, "password" => "[FILTERED]",
                                 "created_at" => "2024-10-07T12:34:56Z" },
                               ["public_data", { "phone_number" => "[FILTERED]" }]
                             ])
    end
  end
end
