module Address
  class Normalizer
    ABBREVIATIONS = {
      "saint" => "st",
      "sainte" => "ste",
      "mont" => "mt",
      "fort" => "ft",
      "chemin" => "chem",
      "avenue" => "av",
      "boulevard" => "bd",
      "place" => "pl",
      "impasse" => "imp",
      "square" => "sq",
      "route" => "rte",
      "cours" => "cr",
      "allée" => "all",
      "quai" => "q",
      "passage" => "psge",
      "faubourg" => "fbg",
      "port" => "pt"
    }.freeze

    def initialize(address)
      @address = address
    end

    def normalize
      return nil if @address.nil?

      normalized_address = @address.downcase
      # Remove accents
      normalized_address = ActiveSupport::Inflector.transliterate(normalized_address)
      normalized_address = normalized_address.gsub(/[-_']/, " ")
      normalized_address = normalized_address.squish
      normalize_abbreviations(normalized_address)
    end

    private

    def normalize_abbreviations(address)
      ABBREVIATIONS.each do |full, abbr|
        address = address.gsub(/\b#{full}\b/, abbr)
      end
      address
    end
  end
end
