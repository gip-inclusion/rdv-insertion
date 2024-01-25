class ChangeHasLoggedInToLastSignInAtForAgents < ActiveRecord::Migration[7.0]
  def change
    add_column :agents, :last_sign_in_at, :datetime

    Agent.find_each do |agent|
      agent.update(last_sign_in_at: Time.zone.now) if agent.has_logged_in?
    end

    remove_column :agents, :has_logged_in, :boolean, default: false, null: false
  end
end
