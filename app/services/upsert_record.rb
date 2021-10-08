class UpsertRecord < BaseService
  def initialize(rdv_solidarites_object:, klass:, additional_attributes: {})
    @rdv_solidarites_object = rdv_solidarites_object
    @klass = klass
    @additional_attributes = additional_attributes
  end

  def call
    record.assign_attributes(
      @rdv_solidarites_object.attributes
                             .slice(*@klass::SHARED_ATTRIBUTES_WITH_RDV_SOLIDARITES)
                             .compact
                             .merge(@additional_attributes)
    )
    record.save! if record.changed?
  end

  private

  def record
    @record ||= @klass.find_or_initialize_by("#{rdv_solidarites_id_attribute_name}": @rdv_solidarites_object.id)
  end

  def rdv_solidarites_id_attribute_name
    "rdv_solidarites_#{@klass.name.downcase}_id"
  end
end
