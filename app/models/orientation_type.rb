class OrientationType < ApplicationRecord
  belongs_to :department, optional: true

  enum :casf_category, { social: "social", pro: "pro", socio_pro: "socio_pro" }

  scope :for_department, lambda { |department|
    custom_orientation_types = where(department:)
    missing_categories = casf_categories.keys - custom_orientation_types.pluck(:casf_category)
    custom_orientation_types.or(default_for_categories(missing_categories))
  }

  scope :default_for_categories, lambda { |categories|
    where(department: nil, casf_category: categories)
  }

  validates :name, presence: true
  validates :casf_category, presence: true

  before_destroy :prevent_deleting_default_orientation_types, :reassign_orientations

  def to_s
    name
  end

  def self.default_for_category(casf_category)
    find_by!(department: nil, casf_category:)
  end

  private

  def default_type? = department.nil?

  def prevent_deleting_default_orientation_types
    return unless default_type?

    errors.add(:base, "Impossible de supprimer un type d'orientation par défaut")
    throw :abort
  end

  def reassign_orientations
    Orientation.where(orientation_type: self)
               .update_all(orientation_type_id: self.class.default_for_category(casf_category).id)
  end
end
