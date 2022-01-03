class AddBirthNameToApplicant < ActiveRecord::Migration[6.1]
  def change
    add_column :applicants, :birth_name, :string
  end
end
