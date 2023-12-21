class Current < ActiveSupport::CurrentAttributes
  attribute :agent, :organisation_id, :department_id, :structure_type, :structure

  def self.department_level?
    structure_type == "department"
  end

  def self.structure
    @structure ||=  department_level? ? Department.find(department_id) : Organisation.find(organisation_id)
  end

  def self.department
    @department ||= department_level? ? structure : structure.department
  end

  def self.organisations_filter
    if department_level?
      { organisations: { department_id: department_id } }
    else
      { organisations: [organisation_id] }
    end
  end

  def self.organisation_filter
    if department_level?
      { organisation: { department_id: department_id } }
    else
      { organisation_id: organisation_id }
    end
  end
end
