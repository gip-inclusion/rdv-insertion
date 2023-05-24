module Applicant::Archivable
  def archived_in?(department)
    archive_for(department.id).present?
  end

  def archive_for(department_id)
    archives.find { |a| a.department_id == department_id }
  end
end
