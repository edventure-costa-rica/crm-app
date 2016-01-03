class AddSupplementalPriceToTrips < ActiveRecord::Migration
  def self.up
    add_column :trips, :supplemental_price, :float, default: 0
  end

  def self.down
    remove_column :trips, :supplemental_price
  end
end
