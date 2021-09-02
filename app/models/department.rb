class Department < ApplicationRecord
  validates :rdv_solidarites_organisation_id, uniqueness: true, allow_nil: true
  validates :name, :capital, :number, presence: true
  has_and_belongs_to_many :agents, dependent: :destroy
  has_many :applicants, dependent: :destroy
  has_one :configuration, dependent: :destroy

  def name_with_region
    "#{name}, #{region}"
  end
end
