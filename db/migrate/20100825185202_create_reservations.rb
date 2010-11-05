class CreateReservations < ActiveRecord::Migration
  def self.up
    create_table :reservations do |t|
      t.references :trip
      t.references :company

      t.datetime :arrival
      t.datetime :departure

      t.string :dropoff_location
      t.string :pickup_location

      t.text :services

      t.text :notes

      t.timestamps
    end
  end

  def self.down
    drop_table :reservations
  end
end
