class AddDepartmentAgents < ActiveRecord::Migration[6.1]
  # from one-to-many to many-to-many
  def change
    create_join_table :departments, :agents do |t|
      t.index [:department_id, :agent_id], unique: true
    end

    up_only do
      Agent.find_each do |agent|
        agent.update(departments: [Department.find(agent.department_id)]) unless agent.department_id.nil?
      end
    end

    remove_reference :agents, :department, null: false, foreign_key: true
  end
end
