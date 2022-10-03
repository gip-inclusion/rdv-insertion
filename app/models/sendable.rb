class Sendable
  attr_reader :resource

  delegate :applicant, :format, :sms_configuration,
           to: :resource
  delegate :email, :phone_number, :phone_number_formatted, :phone_number_is_mobile?, :department_number,
           to: :applicant

  def initialize(resource)
    @resource = resource
  end

  def sms_sender_name
    sms_configuration&.sender_name || "Dept#{department_number}"
  end
end
