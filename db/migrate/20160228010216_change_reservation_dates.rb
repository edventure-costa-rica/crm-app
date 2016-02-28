class ChangeReservationDates < ActiveRecord::Migration
  def self.up
    change_table :reservations do |t|
      t.integer :day, default: 0, null: false
      t.integer :nights, default: 1, null: false
      t.rename :pickup_location, :pick_up
      t.rename :dropoff_location, :drop_off
      t.remove :arrival, :arrival_time,
               :departure, :departure_time
    end
  end

  def self.down
    change_table :reservations do |t|
      t.remove :day, :nights
      t.date :arrival
      t.string :arrival_time
      t.date :departure
      t.string :departure_time
    end
  end
end
