class AddVerticaleToOrganisations < ActiveRecord::Migration[7.0]
  def up
    add_column :organisations, :verticale, :string, default: "rdv_insertion", null: false

    # Migrating rdv_insertion organisations will be done on rdv-solidarites demo and prod manually :
    # Organisation.where(id: [rdv_insertion_orgs_ids]).each { |org| org.verticale = :rdv_insertion; org.save }
  end

  def down
    remove_column :organisations, :verticale
  end
end
