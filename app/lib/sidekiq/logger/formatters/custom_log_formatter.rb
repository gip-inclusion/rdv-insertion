module Sidekiq
  class Logger
    module Formatters
      class CustomLogFormatter < Pretty
        def call(severity, time, program_name, message)
          message = filter_message(message) if message.include?("Job raised exception")

          super(severity, time, program_name, message)
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
