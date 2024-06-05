class OrientationType < ApplicationRecord
  belongs_to :department, optional: true

  enum casf_category: { social: "social", pro: "pro", socio_pro: "socio_pro" }

  scope :for_department, lambda { |department|
    where(department: department)
      .or(where(department: nil))
      .order(:department_id)
      .group_by(&:casf_category)
      .values
      .map(&:first)
  }

  validates :name, presence: true
  validates :casf_category, presence: true

  def to_s
    name
  end
end
