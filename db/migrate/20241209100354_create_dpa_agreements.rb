class CreateDpaAgreements < ActiveRecord::Migration[7.1]
  def change
    create_table :dpa_agreements do |t|
      t.references :organisation, null: false, foreign_key: true
      t.references :agent, null: false, foreign_key: true

      t.timestamps
    end
  end
end
