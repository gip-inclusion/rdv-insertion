class FlashMessage
  attr_reader :type, :title, :description, :link, :persist

  def self.from_type_and_value(value, type:)
    if value.is_a?(String)
      new(description: value, type:)
    elsif value.is_a?(Hash)
      new(**value.deep_symbolize_keys.merge(type:))
    end
  end

  def initialize(type:, description:, title: nil, link: nil, persist: false)
    @type = type
    @title = title
    @description = description
    @link = link
    @persist = persist
  end

  def persist?
    @persist || @type == :error
  end

  def link_url
    @link[:url]
  end

  def link_text
    @link[:text]
  end
end
