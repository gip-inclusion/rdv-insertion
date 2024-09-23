class ApplicationJob < ActiveJob::Base
  include EnvironmentsHelper

  queue_as :default

  def self.perform_in(wait_time, *)
    set(wait: wait_time).perform_later(*)
  end

  private

  class FailedServiceError < StandardError; end

  def call_service!(service_class, **kwargs)
    service_result = service_class.call(**kwargs)
    return service_result if service_result.success?

    Sentry.configure_scope do |scope|
      scope.set_context(:service, { class: service_class, kwargs: })
    end

    raise(
      ApplicationJob::FailedServiceError,
      "Calling service #{service_class} failed in #{self.class}:\n" \
      "Errors: #{service_result.errors}"
    )
  end
end
