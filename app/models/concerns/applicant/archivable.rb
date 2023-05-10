module Applicant::Archivable
  def archived_in?(department)
    archiving_for(department.id).present?
  end

  def archiving_for(department_id)
    archivings.find { |a| a.department_id == department_id }
  end
end
