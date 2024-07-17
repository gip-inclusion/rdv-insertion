module User::CreationOrigin
  extend ActiveSupport::Concern

  included do
    enum created_through: {
      rdv_insertion_upload_page: "rdv_insertion_upload_page",
      rdv_insertion_user_form: "rdv_insertion_user_form",
      rdv_insertion_api: "rdv_insertion_api",
      rdv_solidarites_webhook: "rdv_solidarites_webhook"
    }, _prefix: true

    belongs_to :created_from_structure, polymorphic: true, optional: true

    validates :created_through, :created_from_structure, presence: true, on: :create

    scope :created_through_rdv_solidarites, -> { where(created_through: "rdv_solidarites_webhook") }
  end

  def created_through_rdv_solidarites? = created_through_rdv_solidarites_webhook?

  def created_through_rdv_insertion? = !created_through_rdv_solidarites?
end
