# This code enables active job logger to use the filter_parameters defined in the `filter_parameters.rb` to
# filter the hash arguments of the jobs. However this does not filter sensitive arguments passed as strings
# where self.log_job_arguments = false should be passed !
# It is taken from https://github.com/rails/rails/pull/34438#issuecomment-233674922

# rubocop:disable Lint/ConstantDefinitionInBlock
Rails.application.config.after_initialize do
  require "active_job/log_subscriber"
  module ActiveJob
    class LogSubscriber < ActiveSupport::LogSubscriber
      private

      alias_method :original_format, :format

      def format(arg)
        if arg.is_a?(Hash)
          parameter_filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
          parameter_filter.filter(arg.transform_values { |value| original_format(value) })
        else
          original_format(arg)
        end
      end
    end
  end
end
# rubocop:enable Lint/ConstantDefinitionInBlock
