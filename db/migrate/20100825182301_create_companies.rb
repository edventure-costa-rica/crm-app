class CreateCompanies < ActiveRecord::Migration
  def self.up
    create_table :companies do |t|
      t.string :name
      t.string :type

      t.text :address
      t.string :country

      t.string :contact_name
      t.string :email
      t.string :phone

      t.text :notes

      t.timestamps
    end
  end

  def self.down
    drop_table :companies
  end
end
