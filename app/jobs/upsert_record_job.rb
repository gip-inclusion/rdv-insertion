class UpsertRecordJob < ApplicationJob
  def perform(class_name, rdv_solidarites_attributes, additional_attributes = {})
    UpsertRecord.call(
      klass: class_name.constantize,
      rdv_solidarites_attributes: rdv_solidarites_attributes,
      additional_attributes: additional_attributes
    )
  end
end
