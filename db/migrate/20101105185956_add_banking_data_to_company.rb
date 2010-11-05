class AddBankingDataToCompany < ActiveRecord::Migration
  def self.up
    add_column :companies, :bank_provider, :string
    add_column :companies, :bank_name, :string
    add_column :companies, :bank_address, :string
    add_column :companies, :bank_aba, :string
    add_column :companies, :bank_swift, :string
    add_column :companies, :bank_beneficiary, :string
    add_column :companies, :bank_client_account, :string
    add_column :companies, :bank_govt_id, :string
    add_column :companies, :bank_govt_id_type, :string
  end

  def self.down
    remove_column :companies, :bank_govt_id_type
    remove_column :companies, :bank_govt_id
    remove_column :companies, :bank_client_account
    remove_column :companies, :bank_beneficiary
    remove_column :companies, :bank_swift
    remove_column :companies, :bank_aba
    remove_column :companies, :bank_address
    remove_column :companies, :bank_name
    remove_column :companies, :bank_provider
  end
end
