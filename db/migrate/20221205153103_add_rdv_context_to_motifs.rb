class AddRdvContextToMotifs < ActiveRecord::Migration[7.0]
  def change
    add_column :motifs, :rdv_context, :boolean, default: false
  end
end
