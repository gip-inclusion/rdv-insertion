class Sendable
  attr_reader :record

  delegate :applicant, :format, :sms_configuration,
           to: :record
  delegate :email, :phone_number, :phone_number_formatted, :phone_number_is_mobile?, :department_number,
           to: :applicant

  def initialize(record)
    @record = record
  end

  def sms_sender_name
    sms_configuration&.sender_name || "Dept#{department_number}"
  end
end
