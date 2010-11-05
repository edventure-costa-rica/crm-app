class AddPriceToReservation < ActiveRecord::Migration
  def self.up
    add_column :reservations, :price, :float
  end

  def self.down
    remove_column :reservations, :price
  end
end
