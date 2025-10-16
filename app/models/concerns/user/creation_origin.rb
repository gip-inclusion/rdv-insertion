module User::CreationOrigin
  extend ActiveSupport::Concern

  ORIGIN_ATTRIBUTES = [:created_through, :created_from_structure_type, :created_from_structure_id].freeze

  included do
    enum :created_through, {
      rdv_insertion_upload_page: "rdv_insertion_upload_page",
      rdv_insertion_user_form: "rdv_insertion_user_form",
      rdv_insertion_api: "rdv_insertion_api",
      rdv_solidarites_webhook: "rdv_solidarites_webhook"
    }, prefix: true

    belongs_to :created_from_structure, polymorphic: true, optional: true

    validates :created_through, :created_from_structure_type, :created_from_structure_id,
              presence: true, on: :create

    # prevent these attributes from being updated
    attr_readonly(*ORIGIN_ATTRIBUTES)

    scope :created_through_rdv_solidarites, -> { where(created_through: "rdv_solidarites_webhook") }
  end

  def imported_from_rdv_solidarites? = created_through_rdv_solidarites_webhook?

  def created_through_rdv_insertion? = !created_through_rdv_solidarites?
end
