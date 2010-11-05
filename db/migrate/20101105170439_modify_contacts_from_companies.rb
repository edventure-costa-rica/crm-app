class ModifyContactsFromCompanies < ActiveRecord::Migration
  def self.up
    change_table :companies do |t|
      t.string :contact_general_name
      t.string :contact_general_phone
      t.string :contact_general_mobile
      t.string :contact_general_email

      t.string :contact_admin_name
      t.string :contact_admin_phone
      t.string :contact_admin_mobile
      t.string :contact_admin_email

      t.string :contact_reservation_name
      t.string :contact_reservation_phone
      t.string :contact_reservation_mobile
      t.string :contact_reservation_email

      t.remove :email, :phone, :contact_name,
               :main_phone, :mobile_phone
    end
  end

  def self.down
    change_table :companies do |t|
      t.remove :contact_general_name
      t.remove :contact_general_phone
      t.remove :contact_general_mobile
      t.remove :contact_general_email

      t.remove :contact_admin_name
      t.remove :contact_admin_phone
      t.remove :contact_admin_mobile
      t.remove :contact_admin_email

      t.remove :contact_reservation_name
      t.remove :contact_reservation_phone
      t.remove :contact_reservation_mobile
      t.remove :contact_reservation_email

      t.string :email
      t.string :phone
      t.string :contact_name
      t.string :main_phone
      t.string :mobile_phone
    end
  end
end
