class FailedServiceError < StandardError; end

class BaseService
  def self.call(*args, **kwargs)
    result = new(*args, **kwargs).call
    OpenStruct.new({ success?: true, failure?: false }.merge(result.is_a?(Hash) ? result : {}))
  rescue FailedServiceError => e
    OpenStruct.new(success?: false, failure?: true, errors: [e.message])
  end

  def call
    raise NotImplementedError
  end

  private

  def fail!(error_message)
    raise FailedServiceError, error_message
  end
end
