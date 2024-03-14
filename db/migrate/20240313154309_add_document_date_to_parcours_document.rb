class AddDocumentDateToParcoursDocument < ActiveRecord::Migration[7.1]
  def change
    add_column :parcours_documents, :document_date, :datetime
  end
end
