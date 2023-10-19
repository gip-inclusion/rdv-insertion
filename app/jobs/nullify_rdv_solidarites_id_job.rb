class NullifyRdvSolidaritesIdJob < ApplicationJob
  def perform(class_name, id)
    resource = class_name.constantize.find_by(id: id)
    return if resource.blank? || resource.try(:deleted?)

    resource.nullify_rdv_solidarites_id
    resource.save!
  end
end
