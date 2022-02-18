class AddPdfStringToInvitation < ActiveRecord::Migration[6.1]
  def change
    add_column :invitations, :pdf_string, :string
  end
end
