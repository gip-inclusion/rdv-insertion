class Current < ActiveSupport::CurrentAttributes
  attribute :agent, :organisation_id, :department_id, :structure_type, :structure
  delegate :rdv_solidarites_client, to: :agent
end
