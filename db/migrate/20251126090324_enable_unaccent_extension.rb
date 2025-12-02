class EnableUnaccentExtension < ActiveRecord::Migration[8.0]
  def change
    enable_extension "unaccent"
  end
end
