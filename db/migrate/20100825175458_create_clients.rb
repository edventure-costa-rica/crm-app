class CreateClients < ActiveRecord::Migration
  def self.up
    create_table :clients do |t|
      t.string :nationality
      t.string :family_name
      t.string :contact_name
      t.string :email
      t.string :phone
      t.text :notes

      t.timestamps
    end
  end

  def self.down
    drop_table :clients
  end
end
