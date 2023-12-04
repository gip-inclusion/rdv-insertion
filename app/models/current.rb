class Current < ActiveSupport::CurrentAttributes
  attribute :agent, :organisation_id, :department_id, :structure_type, :structure,
            :organisation, :department
end
