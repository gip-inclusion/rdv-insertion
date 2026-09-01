class CreateRdvSolidaritesOauthTokens < ActiveRecord::Migration[8.1]
  def change
    create_table :rdv_solidarites_oauth_tokens do |t|
      t.references :agent, null: false, foreign_key: true, index: { unique: true }
      t.text :api_token, null: false
      t.text :refresh_token, null: false

      t.timestamps
    end
  end
end
