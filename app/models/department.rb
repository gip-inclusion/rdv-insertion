class Department < ApplicationRecord
  validates :name, :capital, :number, :pronoun, presence: true

  has_many :organisations, dependent: :nullify
  has_many :applicants, dependent: :nullify
  has_many :invitations, dependent: :nullify
  has_many :configurations, through: :organisations

  has_many :agents, through: :organisations
  has_many :rdvs, through: :organisations
  has_many :rdv_contexts, through: :applicants

  def name_with_region
    "#{name}, #{region}"
  end

  def motif_categories
    configurations.map(&:motif_category).uniq
  end

  def logo_format
    %w[svg png jpg].find do |format|
      Webpacker.manifest.lookup("media/images/logos/#{name.parameterize}.#{format}")
    end
  end
end
