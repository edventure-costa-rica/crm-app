class AddMailedAtToReservation < ActiveRecord::Migration
  def self.up
    add_column :reservations, :mailed_at, :datetime, null: true
  end

  def self.down
    remove_column :reservations, :mailed_at
  end
end
