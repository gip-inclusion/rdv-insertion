class UpsertRecord < BaseService
  def initialize(rdv_solidarites_attributes:, klass:, additional_attributes: {})
    @rdv_solidarites_attributes = rdv_solidarites_attributes.deep_symbolize_keys
    @klass = klass
    @additional_attributes = additional_attributes.deep_symbolize_keys
  end

  def call
    @klass.with_advisory_lock(
      "upserting_#{rdv_solidarites_class_name}_rdv_solidarites_id_#{@rdv_solidarites_attributes[:id]}"
    ) do
      return if old_update?

      record.assign_attributes(
        @rdv_solidarites_attributes
          .slice(*@klass::SHARED_ATTRIBUTES_WITH_RDV_SOLIDARITES)
          .merge(@additional_attributes)
      )
      record.save!
    end
  end

  private

  def record
    @record ||= @klass.find_or_initialize_by("#{rdv_solidarites_id_attribute_name}": @rdv_solidarites_attributes[:id])
  end

  def old_update?
    record.persisted? && record.last_webhook_update_received_at.present? &&
      timestamp.present? && timestamp < record.last_webhook_update_received_at
  end

  def timestamp
    @additional_attributes[:last_webhook_update_received_at]&.to_datetime
  end

  def rdv_solidarites_id_attribute_name
    "rdv_solidarites_#{rdv_solidarites_class_name}_id"
  end

  def rdv_solidarites_class_name
    @klass.name.underscore
  end
end
