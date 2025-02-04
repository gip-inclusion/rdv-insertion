# This class is used to filter the error log messages that outputs sidekiq when a job fails.
# Indeed Sidekiq emits a message (even though we use ActiveJob) with the job arguments.
# We override the Sidekiq log formatter to filter out the sensitive values in that case
module Sidekiq
  class Logger
    module Formatters
      class CustomLogFormatter < Pretty
        def call(severity, time, program_name, message)
          # rubocop:disable Layout/LineLength
          # message would look like this in the case of a job failure: "{\"context\":\"Job raised exception\",\"job\":{\"retry\":true,\"queue\":\"default\",\"wrapped\":\"InboundWebhooks::RdvSolidarites::ProcessUserJob\",\"args\":[{\"job_class\":\"InboundWebhooks::RdvSolidarites::ProcessUserJob\",\"job_id\":\"a697fd37-8ece-4707-9b89-15bf569b1b87\",\"provider_job_id\":null,\"queue_name\":\"default\",\"priority\":null,\"arguments\":[{\"id\":549,\"address\":null,\"address_details\":null,\"affiliation_number\":\"\",\"birth_date\":null,\"birth_name\":null,\"caisse_affiliation\":null,\"case_number\":null,\"created_at\":\"2024-09-25 17:41:22 +0200\",\"email\":\"neal@maupay.com\",\"family_situation\":null,\"first_name\":\"Neal\",\"invitation_accepted_at\":null,\"invitation_created_at\":null,\"last_name\":\"Maupay\",\"logement\":null,\"notes\":\"\",\"notify_by_email\":true,\"notify_by_sms\":true,\"number_of_children\":null,\"phone_number\":\"\",\"phone_number_formatted\":null,\"responsible\":null,\"responsible_id\":null,\"user_profiles\":null,\"_aj_hash_with_indifferent_access\":true},{\"model\":\"User\",\"event\":\"updated\",\"webhook_reason\":null,\"timestamp\":\"2024-10-08 22:29:50 +0200\",\"_aj_hash_with_indifferent_access\":true}],\"executions\":0,\"exception_executions\":{},\"locale\":\"fr\",\"timezone\":\"Paris\",\"enqueued_at\":\"2024-10-08T20:29:51.310595000Z\",\"scheduled_at\":null}],\"class\":\"ActiveJob::QueueAdapters::SidekiqAdapter::JobWrapper\",\"jid\":\"fb57cf884d694b8e04d13b1b\",\"created_at\":1728419391.310712,\"current_agent_id\":null,\"trace_propagation_headers\":{\"sentry-trace\":\"a2ccf10271704436b5a8828cdfd594ab-06a33099cad44047\",\"baggage\":\"sentry-trace_id=a2ccf10271704436b5a8828cdfd594ab,sentry-environment=\"},\"enqueued_at\":1728419391.310851}}"
          # rubocop:enable Layout/LineLength
          message = filter_message(message) if message.include?("Job raised exception")

          super
        end

        private

        def filter_message(message)
          job_hash = ::JSON.parse(message)
          sidekiq_args = job_hash.dig("job", "args")
          return message unless sidekiq_args

          sidekiq_args.each do |arg|
            ::Sidekiq::ArgumentsFilter.filter_arguments!(arg["arguments"]) if arg.is_a?(Hash) && arg.key?("arguments")
          end

          job_hash.to_json
        rescue ::JSON::ParserError
          message # If parsing fails in the case the message is not a json string we return the original message
        end
      end
    end
  end
end
