class AddColumnsToParticipations < ActiveRecord::Migration[8.0]
  def change
    add_column :participations, :created_by_agent_prescripteur, :boolean, default: false
    add_column :participations, :created_by_type, :string
    add_column :participations, :rdv_solidarites_created_by_id, :bigint
  end
end
