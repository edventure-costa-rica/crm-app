class RemoveTypeFromCompany < ActiveRecord::Migration
  def self.up
    remove_column :companies, :type
  end

  def self.down
    add_column :companies, :type, :string
  end
end
