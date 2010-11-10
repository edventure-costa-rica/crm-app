class AddInclusiveToCompany < ActiveRecord::Migration
  def self.up
    add_column :companies, :all_inclusive, :boolean
    add_column :companies, :includes_transport, :boolean
    add_column :companies, :includes_tour, :boolean
  end

  def self.down
    remove_column :companies, :includes_tour
    remove_column :companies, :includes_transport
    remove_column :companies, :all_inclusive
  end
end
