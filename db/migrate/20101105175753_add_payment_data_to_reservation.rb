class AddPaymentDataToReservation < ActiveRecord::Migration
  def self.up
    change_table :reservations do |t|
      t.boolean :confirmed
      t.string  :confirmation_no
      t.boolean :paid
      t.date    :paid_date
    end
  end

  def self.down
    change_table :reservations do |t|
      t.remove :confirmed
      t.remove :confirmation_no
      t.remove :paid
      t.remove :paid_date
    end
  end
end
