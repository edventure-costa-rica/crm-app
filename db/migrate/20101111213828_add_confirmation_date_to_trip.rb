class AddConfirmationDateToTrip < ActiveRecord::Migration
  def self.up
    add_column :trips, :confirmation_date, :date
  end

  def self.down
    remove_column :trips, :confirmation_date
  end
end
