class ChangeAgentIdNullConstraintOnParcoursDocuments < ActiveRecord::Migration[7.1]
  def change
    change_column_null :parcours_documents, :agent_id, true
  end
end
