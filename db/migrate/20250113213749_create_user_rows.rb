class CreateUserRows < ActiveRecord::Migration[7.1]
  def change
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")

    create_table :user_rows, id: :uuid do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :phone_number
      t.string :role
      t.string :title
      t.string :nir
      t.string :department_internal_id
      t.string :france_travail_id
      t.date :rights_opening_date
      t.string :affiliation_number
      t.date :birth_date
      t.string :birth_name
      t.string :address
      t.string :organisation_search_terms
      t.string :referent_email
      t.string :tag_values, array: true, default: []
      t.references :matching_user, foreign_key: { to_table: :users }
      t.references :user_list_upload, null: false, foreign_key: true, type: :uuid
      t.integer :assigned_organisation_id
      t.json :cnaf_data, default: {}
      t.boolean :marked_for_invitation, default: false
      t.boolean :marked_for_user_save, default: false

      t.timestamps
    end

    add_index :user_rows, :assigned_organisation_id
  end
end
