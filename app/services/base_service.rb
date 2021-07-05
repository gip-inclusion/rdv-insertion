class FailedServiceError < StandardError; end

class UnexpectedResultBehaviourError < StandardError; end

class BaseService
  class << self
    def call(*args, **kwargs)
      service = new(*args, **kwargs)
      service.instance_variable_set(:@result, OpenStruct.new(errors: []))
      service.call
      format_result(service.result)
    rescue FailedServiceError => e
      errors = service.result.errors
      raise UnexpectedResultBehaviourError unless errors.is_a? Array

      # we add the exception message only if it is a custom message
      errors << e.message if e.message != e.class.to_s
      OpenStruct.new(success?: false, failure?: true, errors: errors)
    end

    def call!
      raise FailedServiceError if call(*args, **kwargs).failure?
    end

    private

    def format_result(result)
      raise UnexpectedResultBehaviourError unless result.is_a? OpenStruct

      result[:success?] = result.errors.blank?
      result[:failure?] = result.errors.present?
      result
    end
  end

  attr_reader :result

  def call
    raise NotImplementedError
  end

  private

  def fail!(error_message = nil)
    raise FailedServiceError, error_message
  end

  def failed?
    result.errors.present?
  end
end
