class AddRegionToCompany < ActiveRecord::Migration
  def self.up
    add_column :companies, :region_id, :integer
  end

  def self.down
    remove_column :companies, :region_id
  end
end
