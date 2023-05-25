module NirHelper
  class << self
    def format_nir(nir)
      return if nir.blank?
      return nir if nir.length != 13

      "#{nir}#{nir_key(nir)}"
    end

    def nir_key(nir)
      key = 97 - (nir.first(13).to_i % 97)
      key.to_s.length == 2 ? key.to_s : "0#{key}"
    end

    def equal?(nir1, nir2)
      format_nir(nir1) == format_nir(nir2)
    end
  end
end
