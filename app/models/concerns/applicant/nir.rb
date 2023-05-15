module Applicant::Nir
  extend ActiveSupport::Concern

  included do
    before_validation :format_nir, if: :nir?
    validate :nir_is_valid, if: :nir?
  end

  private

  def format_nir
    self.nir = NirHelper.format_nir(nir)
  end

  def nir_is_valid
    if nir.length != 15 || nir !~ /\A\d+\Z/
      errors.add(:nir, :invalid, message: "Le NIR doit être une série de 13 ou 15 chiffres")
      return
    end

    return if nir_sum_checked?

    errors.add(:nir, :invalid, message: "Le NIR n'est pas valide")
  end

  def nir_sum_checked?
    NirHelper.nir_key(nir) == nir.last(2)
  end
end
