module NirHelper
  class << self
    def format_nir(nir)
      return if nir.blank?

      nir = nir.strip.upcase
      return nir if nir.length != 13

      "#{nir}#{nir_key(nir)}"
    end

    def nir_key(nir)
      key = 97 - (nir_without_corsica_letters(nir).first(13).to_i % 97)
      key.to_s.length == 2 ? key.to_s : "0#{key}"
    end

    def nir_without_corsica_letters(nir)
      # people born in Corsica have "2A" or "2B" in their nirs ; this method deals with this case
      return nir unless nir.match?(/\A\d+(2A|2B){1}\d+\z/)

      nir.match?(/2A/) ? nir.gsub("2A", "19") : nir.gsub("2B", "18")
    end
  end
end
