class AddIndexOnStatus < ActiveRecord::Migration[6.1]
  def change
    add_index "applicants", ["status"]
  end
end
