class CreatePeople < ActiveRecord::Migration
  def self.up
    create_table :people do |t|
      t.string :full_name
      t.string :passport_number
      t.string :passport_country
      t.date :dob

      t.references :trip

      t.timestamps
    end
  end

  def self.down
    drop_table :people
  end
end
