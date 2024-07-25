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

    before_update :reset_origin_attributes_if_changed

    scope :created_through_rdv_solidarites, -> { where(created_through: "rdv_solidarites_webhook") }
  end

  def created_through_rdv_solidarites? = created_through_rdv_solidarites_webhook?

  def created_through_rdv_insertion? = !created_through_rdv_solidarites?

  private

  def reset_origin_attributes_if_changed
    [:created_through, :created_from_structure_id, :created_from_structure_type].each do |attribute_name|
      public_send("#{attribute_name}=", attribute_was(attribute_name)) if attribute_changed?(attribute_name)
    end
  end
end
