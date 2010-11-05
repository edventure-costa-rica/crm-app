class AddStatusToTrip < ActiveRecord::Migration
  def self.up
    add_column :trips, :status, :string
    add_column :trips, :payment_pct, :integer
    add_column :trips, :payment_date, :text
  end

  def self.down
    remove_column :trips, :payment_date
    remove_column :trips, :payment_pct
    remove_column :trips, :status
  end
end
