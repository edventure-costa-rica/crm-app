class AddNetPriceToReservation < ActiveRecord::Migration
  def self.up
    add_column :reservations, :net_price, :float
  end

  def self.down
    remove_column :reservations, :net_price
  end
end
