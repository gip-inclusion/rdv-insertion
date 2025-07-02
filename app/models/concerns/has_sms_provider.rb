module HasSmsProvider
  extend ActiveSupport::Concern

  included do
    enum :sms_provider, { brevo: "brevo", primotexto: "primotexto" }, prefix: true

    before_validation :set_sms_provider, on: :create, if: :format_sms?

    validates :sms_provider, presence: true, if: :format_sms?
  end

  class_methods do
    def force_primotexto? = ENV["FORCE_PRIMOTEXTO"] == "true"

    def primotexto_available? = ENV["PRIMOTEXTO_API_KEY"].present?
  end

  def sms_sent_with_brevo?
    format_sms? && sms_provider == "brevo"
  end

  def sms_sent_with_primotexto?
    format_sms? && sms_provider == "primotexto"
  end

  private

  def set_sms_provider
    return unless format_sms?

    self.sms_provider = self.class.force_primotexto? && self.class.primotexto_available? ? "primotexto" : "brevo"
  end
end
