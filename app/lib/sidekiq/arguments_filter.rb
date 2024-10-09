module Sidekiq
  module ArgumentsFilter
    def self.filter_arguments!(job_args)
      job_args.map! do |arg|
        filter_sensitive_values!(arg)
      end
    end

    def self.filter_sensitive_values!(data)
      case data
      when Hash
        parameter_filter.filter(data)
      when Array
        data.map! { |value| filter_sensitive_values!(value) }
      else
        data
      end
    end

    # defined in config/initializers/filter_parameters.rb
    def self.parameter_filter = ActiveSupport::ParameterFilter.new(::Rails.application.config.filter_parameters)
  end
end
