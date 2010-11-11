class AddPackageToCompany < ActiveRecord::Migration
  def self.up
    add_column :companies, :package, :string
  end

  def self.down
    remove_column :companies, :package
  end
end
