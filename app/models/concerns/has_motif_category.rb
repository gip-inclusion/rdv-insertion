module HasMotifCategory
  extend ActiveSupport::Concern

  included do
    enum motif_category: Motif::CATEGORIES_ENUM
  end

  def motif_category_human
    Motif::CATEGORIES_NAMES_MAPPING[motif_category]
  end
end
