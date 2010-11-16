class AddBankProviderBackToCompany < ActiveRecord::Migration
  def self.up
    add_column :companies, :bank_provider, :string
  end

  def self.down
    remove_column :companies, :bank_provider
  end
end
