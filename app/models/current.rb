class Current < ActiveSupport::CurrentAttributes
  attribute :agent
  delegate :rdv_solidarites_client, to: :agent
end
