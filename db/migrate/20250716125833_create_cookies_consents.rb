class CreateCookiesConsents < ActiveRecord::Migration[8.0]
  def change
    create_table :cookies_consents do |t|
      t.boolean :support_accepted, default: false
      t.boolean :tracking_accepted, default: false
      t.references :agent, null: false, foreign_key: true

      t.timestamps
    end
  end
end
