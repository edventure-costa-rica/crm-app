class AddPackageLengthToCompanies < ActiveRecord::Migration
  def self.up
    add_column :companies, :package_length, :integer
  end

  def self.down
    remove_column :companies, :package_length
  end
end
