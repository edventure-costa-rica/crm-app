class AddBankAccountToCompany < ActiveRecord::Migration
  def self.up
    add_column :companies, :bank_account, :string
  end

  def self.down
    remove_column :companies, :bank_account
  end
end
