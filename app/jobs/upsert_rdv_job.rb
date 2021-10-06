class UpsertRdvJob < ApplicationJob
  def perform(rdv_attributes, applicant_ids, department_id)
    UpsertRecord.call(
      klass: Rdv, rdv_solidarites_object: RdvSolidarites::Rdv.new(rdv_attributes),
      additional_attributes: {
        applicant_ids: applicant_ids,
        department_id: department_id
      }
    )
  end
end
