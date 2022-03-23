class CreateResponsibles < ActiveRecord::Migration[6.1]
  def change
    create_table :responsibles do |t|
      t.string :first_name
      t.string :last_name

      t.timestamps
    end

    add_reference :organisations, :responsible, foreign_key: true
  end
end
