module Applicant::Nir
  extend ActiveSupport::Concern

  included do
    before_validation :add_nir_key, if: :nir?
    validate :nir_is_valid, if: :nir?
  end

  private

  def add_nir_key
    return unless nir.length == 13

    self.nir = "#{nir}#{nir_key}"
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
    nir_key == nir.last(2).to_i
  end

  def nir_key
    97 - (nir.first(13).to_i % 97)
  end
end
