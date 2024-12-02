module User::BirthDateValidation
  extend ActiveSupport::Concern

  included do
    validate :birth_date_validity
  end

  private

  def birth_date_validity
    return if birth_date.blank?
    return unless birth_date.present? && (birth_date > Time.zone.today || birth_date < 130.years.ago)

    errors.add(:birth_date, "n'est pas valide")
  end
end
