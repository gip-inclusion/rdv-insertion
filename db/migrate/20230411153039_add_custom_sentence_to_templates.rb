class AddCustomSentenceToTemplates < ActiveRecord::Migration[7.0]
  def change
    add_column :templates, :custom_sentence, :text
  end
end
