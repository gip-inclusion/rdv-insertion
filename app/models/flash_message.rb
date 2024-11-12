class FlashMessage
  attr_accessor :title, :description, :link, :persist

  def self.from_type_and_value(value, type:)
    if value.is_a?(String)
      new(description: value, type:)
    elsif value.is_a?(Hash)
      new(**value, type:)
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
end
