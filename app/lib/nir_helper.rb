module NirHelper
  class << self
    def format_nir(nir)
      return if nir.blank?
      return nir if nir.length != 13

      "#{nir}#{nir_key(nir)}"
    end

    def nir_key(nir)
      97 - (nir.first(13).to_i % 97)
    end
  end
end
