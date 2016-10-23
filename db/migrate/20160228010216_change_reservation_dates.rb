class ChangeReservationDates < ActiveRecord::Migration
  class Reservation < ActiveRecord::Base
  end

  def self.up
    change_table :reservations do |t|
      t.integer :day, default: 0, null: false
      t.integer :nights, default: 1, null: false
    end

    migrate_reservation_dates

    change_table :reservations do |t|
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

  def self.migrate_reservation_dates
    Trip.find_each do |trip|
      trip.reservations.each do |res|
        day = res.arrival.to_date - trip.arrival.to_date
        nights = res.departure.to_date - res.departure.to_date
        
        res.update_attributes day: day, nights: nights
      end
    end

    Reservation.reset_column_information
  end
end
