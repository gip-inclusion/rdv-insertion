class AddNullConstraintOnMotifBookingDelays < ActiveRecord::Migration[8.1]
  def change
    change_column_null :motifs, :min_public_booking_delay, false
    change_column_null :motifs, :max_public_booking_delay, false
  end
end
