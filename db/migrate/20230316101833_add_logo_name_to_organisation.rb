class AddLogoNameToOrganisation < ActiveRecord::Migration[7.0]
  def change
    add_column :organisations, :logo_filename, :string

    Organisation.find_each do |organisation|
      organisation.logo_filename = organisation.name.parameterize
      organisation.save!
    end
  end
end
