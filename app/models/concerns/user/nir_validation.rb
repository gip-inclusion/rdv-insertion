module User::NirValidation
  extend ActiveSupport::Concern

  included do
    validate :nir_is_valid, if: :nir?

    # We add this validation only upon create to avoid blocking the updates of existing users
    validate :nir_is_coherent_with_title, on: :create, if: :nir?
    validate :nir_is_coherent_with_birth_date, on: :create, if: :nir?
  end

  private

  def nir_is_valid
    # nir should be only digits, except for people born in Corsica who have "2A" or "2B" in their nirs
    if nir.length != 15 || nir !~ /\A\d+(2A|2B){0,1}\d+\z/
      errors.add(:nir, :invalid, message: "Le NIR doit être une série de 13 ou 15 chiffres")
      return
    end

    return if nir_sum_checked?

    errors.add(:nir, :invalid, message: "Le NIR n'est pas valide")
  end

  def nir_is_coherent_with_title
    if monsieur? && nir.starts_with?("2")
      errors.add(:nir, :invalid, message: "Le NIR ne peut commencer par 2 pour un homme")
    elsif madame? && nir.starts_with?("1")
      errors.add(:nir, :invalid, message: "Le NIR ne peut commencer par 1 pour une femme")
    end
  end

  def nir_is_coherent_with_birth_date
    return if birth_date.blank?
    return if nir[1..2] == birth_date.strftime("%y")

    errors.add(:nir, :invalid,
               message: "L'année de naissance inclue dans le NIR ne correspond pas à la date de naissance")
  end

  def nir_sum_checked?
    NirHelper.nir_key(nir) == nir.last(2)
  end
end
