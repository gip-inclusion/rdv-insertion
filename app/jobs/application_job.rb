class ApplicationJob
  class ServiceError < StandardError; end

  include Sidekiq::Worker
  include EnvironmentsHelper

  private

  def call_service!(service, **kwargs)
    service_result = service.call(**kwargs)
    return service_result if service_result.success?

    raise(
      ServiceError,
      "call to #{service} in #{self.class} failed with the following errors: \n" \
      "#{service_result.errors}"
    )
  end
end
