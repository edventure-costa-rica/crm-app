class AddFlightToTrip < ActiveRecord::Migration
  def self.up
    add_column :trips, :arrival_flight, :string
    add_column :trips, :departure_flight, :string
  end

  def self.down
    remove_column :trips, :departure_flight
    remove_column :trips, :arrival_flight
  end
end
