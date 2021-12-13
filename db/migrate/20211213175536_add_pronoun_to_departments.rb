class AddPronounToDepartments < ActiveRecord::Migration[6.1]
  def change
    add_column :departments, :pronoun, :string
  end
end
