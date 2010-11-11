class AddContactAddressToClient < ActiveRecord::Migration
  def self.up
    add_column :clients, :contact_address, :string
  end

  def self.down
    remove_column :clients, :contact_address
  end
end
