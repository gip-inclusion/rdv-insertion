class FailedServiceError < StandardError; end

class BaseService
  class << self
    def call(*args, **kwargs)
      result = new(*args, **kwargs).call
      result_as_open_struct(result)
    rescue FailedServiceError => e
      OpenStruct.new(success?: false, failure?: true, errors: [e.message])
    end

    private

    def result_as_open_struct(result)
      return OpenStruct.new(success?: true, failure?: false) unless result.is_a? Hash

      OpenStruct.new({
        success?: result[:errors].blank?, failure?: result[:errors].present?
      }.merge(result))
    end
  end

  def call
    raise NotImplementedError
  end

  private

  def fail!(error_message)
    raise FailedServiceError, error_message
  end
end
