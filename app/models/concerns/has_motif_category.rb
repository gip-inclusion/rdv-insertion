module HasMotifCategory
  extend ActiveSupport::Concern

  included do
    enum motif_category: Motif::CATEGORIES_ENUM
  end

  def motif_category_human
    I18n.t("activerecord.attributes.motif.categories.#{motif_category}")
  end
end
