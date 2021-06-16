class FailedServiceError < StandardError; end

class BaseService
  def self.call(*args, **kwargs)
    result = new(*args, **kwargs).call
    if result.is_a? Hash
      OpenStruct.new({ success?: true, failure?: false }.merge(result))
    else
      OpenStruct.new(success?: true, failure?: false)
    end
  rescue FailedServiceError => e
    OpenStruct.new(success?: false, failure?: true, errors: [e.message])
  end

  private

  def fail!(error_message)
    raise FailedServiceError, error_message
  end

  def call
    raise NotImplementedError
  end
end
