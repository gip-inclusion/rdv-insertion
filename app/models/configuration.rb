class Configuration < ApplicationRecord
  belongs_to :motif_category
  belongs_to :file_configuration
  has_many :configurations_organisations, dependent: :delete_all
  has_many :organisations, through: :configurations_organisations

  validate :delays_validity

  delegate :position, :name, to: :motif_category, prefix: true

  def as_json(opts = {})
    super.merge(
      # TODO: delegate these methods to file_configuration
      sheet_name: file_configuration.sheet_name,
      column_names: file_configuration.column_names
    )
  end

  private

  def delays_validity
    return if number_of_days_to_accept_invitation <= number_of_days_before_action_required

    errors.add(:base, "Le délai de prise de rendez-vous communiqué au bénéficiaire ne peut pas être inférieur " \
                      "au délai d'expiration de l'invtation")
  end
end
