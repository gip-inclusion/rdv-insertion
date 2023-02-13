class CreateAgentRolesTable < ActiveRecord::Migration[7.0]
  def up
    create_table :agent_roles do |t|
      t.integer :level, default: 0, null: false
      t.references :agent, null: false, foreign_key: true
      t.references :organisation, null: false, foreign_key: true
      t.bigint :rdv_solidarites_agent_role_id

      t.timestamps
    end

    add_index "agent_roles", ["level"]
    add_index "agent_roles", ["rdv_solidarites_agent_role_id"], unique: true
    add_index "agent_roles", %w[agent_id organisation_id], unique: true

    execute "insert into agent_roles(agent_id, organisation_id, created_at, updated_at)
      select agent_id,organisation_id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
      from agents_organisations"

    drop_table :agents_organisations
  end

  def down
    create_join_table :agents, :organisations do |t|
      t.index [:agent_id, :organisation_id], unique: true
    end

    execute "insert into agents_organisations(agent_id,organisation_id) select agent_id,organisation_id
      from agent_roles"

    drop_table :agent_roles
  end
end
