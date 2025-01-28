class ApplicationJob < ActiveJob::Base
  include EnvironmentsHelper

  class FailedServiceError < StandardError; end
  class NonRetryableError < StandardError; end

  discard_on NonRetryableError
  queue_as :default

  def self.perform_in(wait_time, *)
    set(wait: wait_time).perform_later(*)
  end

  # InboundWebhooks::RdvSolidarites::ProcessRdvJob => lock:inbound_webhooks:rdv_solidarites:process_rdv_job
  def self.base_lock_key = "lock:#{name.split('::').map(&:underscore).join(':')}"

  private

  def call_service!(service_class, **kwargs)
    service_result = service_class.call(**kwargs)
    return service_result if service_result.success?

    Sentry.configure_scope do |scope|
      scope.set_context(:service, { class: service_class, kwargs: })
    end

    error_message = "Calling service #{service_class} failed in #{self.class}:\n" \
                    "Errors: #{service_result.errors.map(&:to_s)}"

    raise(NonRetryableError, error_message) if service_result.non_retryable_error

    raise(FailedServiceError, error_message)
  end
end
