class UpsertRecord < BaseService
  def initialize(rdv_solidarites_attributes:, klass:, additional_attributes: {})
    @rdv_solidarites_attributes = rdv_solidarites_attributes.deep_symbolize_keys
    @klass = klass
    @additional_attributes = additional_attributes.deep_symbolize_keys
  end

  def call
    record.assign_attributes(
      @rdv_solidarites_attributes
        .slice(*@klass::SHARED_ATTRIBUTES_WITH_RDV_SOLIDARITES)
        .compact
        .merge(@additional_attributes)
    )
    record.save! if record.changed?
  end

  private

  def record
    @record ||= @klass.find_or_initialize_by("#{rdv_solidarites_id_attribute_name}": @rdv_solidarites_attributes[:id])
  end

  def rdv_solidarites_id_attribute_name
    "rdv_solidarites_#{@klass::RDV_SOLIDARITES_CLASS_NAME.downcase}_id"
  end
end
