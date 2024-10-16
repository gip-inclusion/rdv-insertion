class FlashMessage
  attr_accessor :title, :description, :link, :persist

  def initialize(description:, title: nil, link: nil, persist: false)
    @title = title
    @description = description
    @link = link
    @persist = persist
  end
end
