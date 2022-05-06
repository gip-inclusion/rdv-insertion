class AddSmsSenderNameToConfiguration < ActiveRecord::Migration[7.0]
  def change
    add_column :configurations, :sms_sender_name, :string, limit: 11
  end
end
