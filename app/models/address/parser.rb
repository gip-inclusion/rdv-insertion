module Address
  class Parser
    POST_CODE_REGEX = /^(.*?\b)?(\d{5})(.*)$/

    def initialize(address)
      @address = address
    end

    def parsed_street_address
      return if split_address_from_post_code.blank?

      split_address_from_post_code[1].strip.gsub(/-$/, "").gsub(/,$/, "").gsub(/\.$/, "")
    end

    def parsed_post_code
      return if split_address_from_post_code.blank?

      split_address_from_post_code[2].strip
    end

    def parsed_city
      return if split_address_from_post_code.blank?

      split_address_from_post_code[3].strip
    end

    def parsed_post_code_and_city
      [parsed_post_code, parsed_city].compact_blank.join(" ").presence
    end

    private

    def split_address_from_post_code
      return if @address.blank?

      @address.match(POST_CODE_REGEX)
    end
  end
end
