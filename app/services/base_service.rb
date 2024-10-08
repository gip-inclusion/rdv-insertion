class FailedServiceError < StandardError; end

class UnexpectedResultBehaviourError < StandardError; end

class BaseService
  class << self
    def call(**)
      service = new(**)
      service.instance_variable_set(:@result, OpenStruct.new(errors: []))
      output = service.call
      format_result(output, service.result)
    rescue FailedServiceError => e
      format_error(service.result, e)
    end

    private

    def format_result(output, result)
      # if the output is a result itself (from other service call), we consider
      # the output instead of the result instance variable
      return output if output.is_a?(OpenStruct) && !output.success?.nil? && !output.failure?.nil?

      add_status_to(result)
    end

    def add_status_to(result)
      raise UnexpectedResultBehaviourError unless result.is_a? OpenStruct

      result[:success?] = result.errors.blank?
      result[:failure?] = result.errors.present?
      result
    end

    def format_error(result, exception)
      errors = result.errors
      raise UnexpectedResultBehaviourError unless errors.is_a? Array

      # we add the exception message only if it is a custom message
      errors << exception.message if exception.message != exception.class.to_s
      result.errors = errors
      result[:success?] = false
      result[:failure?] = true
      result
    end
  end

  attr_reader :result

  def call
    raise NoMethodError
  end

  private

  def add_custom_error(message:, template_name:, locals: {})
    result.errors << TemplatedErrorPresenter.new(message: message, template_name: template_name, locals: locals)
  end

  def call_service!(service_class, **)
    service_result = service_class.call(**)
    return service_result if service_result.success?

    service_result.to_h.each { |key, value| result[key] = value }
    fail!
  end

  def save_record!(record)
    return if record.save

    result.errors << record.errors.full_messages.to_sentence
    fail!
  end

  def fail!(error_message = nil)
    raise FailedServiceError, error_message
  end
end
