class Reservation < ActiveRecord::Migration
  class Reservation < ActiveRecord::Base; end
  class Trip < ActiveRecord::Base; end

  def self.up
    add_column :reservations, :num_people, :integer, { :null => true }
    Reservation.find_each do |res|
      trip = Trip.find(res.trip_id)
      res.num_people = trip.total_people unless trip.nil?
      res.save
    end
  end

  def self.down
    remove_column :reservations, :num_people
  end
end
