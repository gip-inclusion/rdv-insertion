class RemoveResponsibles < ActiveRecord::Migration[7.0]
  def change
    remove_reference :organisations, :responsible, foreign_key: true
    drop_table :responsibles do |t|
      t.string :first_name
      t.string :last_name

      t.timestamps
    end
  end
end
