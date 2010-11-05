class AddGenderToClient < ActiveRecord::Migration
  def self.up
    add_column :clients, :contact_gender, :string
    add_column :clients, :contact_title, :string
  end

  def self.down
    remove_column :clients, :contact_title
    remove_column :clients, :contact_gender
  end
end
