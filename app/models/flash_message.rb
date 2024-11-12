class FlashMessage
  attr_accessor :title, :description, :link, :persist

  def self.from_string(description)
    new(description:)
  end

  def self.from_hash(hash)
    new(**hash)
  end

  def self.from_string_or_hash(string_or_hash)
    if string_or_hash.is_a?(String)
      from_string(string_or_hash)
    elsif string_or_hash.is_a?(Hash)
      from_hash(string_or_hash)
    end
  end

  def initialize(description:, title: nil, link: nil, persist: false)
    @title = title
    @description = description
    @link = link
    @persist = persist
  end
end
