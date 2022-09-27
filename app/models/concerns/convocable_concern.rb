module ConvocableConcern
  extend ActiveSupport::Concern

  included do
    has_many :convocations, dependent: :destroy
  end

  def convened?
    convocations.any?(&:sent_at)
  end

  def last_sent_convocation
    convocations.select(&:sent_at).max_by(&:sent_at)
  end

  def last_convocation_sent_at
    last_sent_convocation&.sent_at
  end
end
