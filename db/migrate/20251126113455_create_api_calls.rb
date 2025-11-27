class CreateApiCalls < ActiveRecord::Migration[8.0]
  def change
    create_table :api_calls do |t|
      t.string :http_method, null: false
      t.string :path, null: false
      t.string :host
      t.string :controller_name, null: false
      t.string :action_name, null: false

      t.references :agent, foreign_key: true

      t.timestamps
    end

    add_index :api_calls, :created_at
  end
end
