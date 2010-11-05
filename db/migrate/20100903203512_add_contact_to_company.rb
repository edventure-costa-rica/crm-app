class AddContactToCompany < ActiveRecord::Migration
  def self.up
    add_column :companies, :city, :string
    add_column :companies, :main_phone, :string
    add_column :companies, :mobile_phone, :string
    add_column :companies, :website, :string
  end

  def self.down
    remove_column :companies, :city
    remove_column :companies, :main_phone
    remove_column :companies, :mobile_phone
    remove_column :companies, :website
  end
end
