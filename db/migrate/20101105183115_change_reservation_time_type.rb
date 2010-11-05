class ChangeReservationTimeType < ActiveRecord::Migration
  def self.up
    change_table :reservations do |t|
      t.change :arrival,   :date
      t.change :departure, :date

      t.string :arrival_time
      t.string :departure_time
    end
  end

  def self.down
    change_table :reservations do |t|
      t.change :arrival,   :datetime
      t.change :departure, :datetime

      t.remove :arrival_time
      t.remove :departure_time
    end
  end
end
