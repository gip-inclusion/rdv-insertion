class AddBookingDelaysToMotifs < ActiveRecord::Migration[8.1]
  def change
    add_column :motifs, :min_public_booking_delay, :integer
    add_column :motifs, :max_public_booking_delay, :integer
  end
end
