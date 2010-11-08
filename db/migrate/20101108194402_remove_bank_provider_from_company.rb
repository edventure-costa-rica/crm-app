class RemoveBankProviderFromCompany < ActiveRecord::Migration
  def self.up
    remove_column :companies, :bank_provider
  end

  def self.down
    add_column :companies, :bank_provider, :string
  end
end
