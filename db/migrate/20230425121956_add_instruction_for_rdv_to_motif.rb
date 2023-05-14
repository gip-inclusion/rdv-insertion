class AddInstructionForRdvToMotif < ActiveRecord::Migration[7.0]
  def change
    add_column :motifs, :instruction_for_rdv, :text, default: ""
  end
end
