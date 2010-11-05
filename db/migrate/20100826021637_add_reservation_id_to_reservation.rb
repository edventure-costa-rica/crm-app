class AddReservationIdToReservation < ActiveRecord::Migration
  def self.up
    add_column :reservations, :reservation_id, :string
  end

  def self.down
    remove_column :reservations, :reservation_id
  end
end
