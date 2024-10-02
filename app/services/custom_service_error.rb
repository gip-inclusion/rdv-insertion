class CustomServiceError < ServiceError
  attr_reader :type, :attributes

  def initialize(message, type:, attributes: {})
    super(message)
    @type = type
    @attributes = attributes
  end

  def to_partial_path
    "common/custom_errors/#{@type}"
  end
end
