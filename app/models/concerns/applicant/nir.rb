module Applicant::Nir
  extend ActiveSupport::Concern

  included do
    validate :nir_is_valid, if: :nir?
  end

  private

  def nir_is_valid
    if nir.length != 15 || nir !~ /\A\d+\Z/
      errors.add(:nir, :invalid, message: "Le NIR doit être une série de 15 chiffres")
      return
    end

    return if nir_sum_checked?

    errors.add(:nir, :invalid, message: "Le NIR n'est pas valide")
  end

  def nir_sum_checked?
    97 - (nir.first(13).to_i % 97) == nir.last(2).to_i
  end
end
