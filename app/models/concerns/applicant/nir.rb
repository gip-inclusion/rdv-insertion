module Applicant::Nir
  extend ActiveSupport::Concern

  included do
    validate :nir_is_valid, if: :nir?
    after_validation :add_nir_key
  end

  private

  def add_nir_key
    self.nir = "#{nir}#{nir_key}" if nir&.length == 13
  end

  def nir_is_valid
    unless (nir.length == 13 || nir.length == 15) && nir.match?(/\A\d+\Z/)
      errors.add(:nir, :invalid, message: "Le NIR doit être une série de 13 ou 15 chiffres")
      return
    end

    return unless nir.length == 15

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
