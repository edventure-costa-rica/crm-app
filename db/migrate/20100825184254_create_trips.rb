class CreateTrips < ActiveRecord::Migration
  def self.up
    create_table :trips do |t|
      t.string :registration_id
      t.index :registration_id, :unique => true

      t.timestamp :arrival
      t.timestamp :departure

      t.integer :total_people
      t.integer :num_children
      t.integer :num_disabled

      t.references :client

      t.text :notes

      t.timestamps
    end
  end

  def self.down
    drop_table :trips
  end
end
