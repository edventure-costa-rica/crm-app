class ChangeReservationNightsDefault < ActiveRecord::Migration
  def self.up
    change_column_default :reservations, :nights, 0
  end

  def self.down
    change_column_default :reservations, :nights, 1
  end
end
