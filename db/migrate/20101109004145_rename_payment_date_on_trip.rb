class RenamePaymentDateOnTrip < ActiveRecord::Migration
  def self.up
    rename_column :trips, :payment_date, :payment_details
  end

  def self.down
    rename_column :trips, :payment_details, :payment_date
  end
end
