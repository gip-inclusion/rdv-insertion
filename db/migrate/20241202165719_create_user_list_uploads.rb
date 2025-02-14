class CreateUserListUploads < ActiveRecord::Migration[7.1]
  def change
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")

    create_table :user_list_uploads, id: :uuid do |t|
      t.string :file_name
      t.references :category_configuration, foreign_key: true
      t.references :structure, null: false, polymorphic: true
      t.references :agent, null: false, foreign_key: true

      t.timestamps
    end
  end
end
