# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20160618224757) do

  create_table "clients", :force => true do |t|
    t.string   "nationality"
    t.string   "family_name"
    t.string   "contact_name"
    t.string   "email"
    t.string   "phone"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "contact_gender"
    t.string   "contact_title"
    t.string   "contact_address"
  end

  create_table "companies", :force => true do |t|
    t.string   "name"
    t.text     "address"
    t.string   "country"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "city"
    t.string   "website"
    t.string   "kind"
    t.string   "contact_general_name"
    t.string   "contact_general_phone"
    t.string   "contact_general_mobile"
    t.string   "contact_general_email"
    t.string   "contact_admin_name"
    t.string   "contact_admin_phone"
    t.string   "contact_admin_mobile"
    t.string   "contact_admin_email"
    t.string   "contact_reservation_name"
    t.string   "contact_reservation_phone"
    t.string   "contact_reservation_mobile"
    t.string   "contact_reservation_email"
    t.string   "bank_name"
    t.string   "bank_address"
    t.string   "bank_aba"
    t.string   "bank_swift"
    t.string   "bank_beneficiary"
    t.string   "bank_client_account"
    t.string   "bank_govt_id"
    t.string   "bank_govt_id_type"
    t.integer  "region_id"
    t.string   "bank_account"
    t.boolean  "all_inclusive"
    t.boolean  "includes_transport"
    t.boolean  "includes_tour"
    t.string   "package"
    t.integer  "package_length"
    t.string   "bank_provider"
  end

  create_table "people", :force => true do |t|
    t.string   "full_name"
    t.string   "passport"
    t.string   "country"
    t.date     "dob"
    t.integer  "trip_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "regions", :force => true do |t|
    t.string   "name"
    t.string   "country"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reservations", :force => true do |t|
    t.integer  "trip_id"
    t.integer  "company_id"
    t.string   "drop_off"
    t.string   "pick_up"
    t.text     "services"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "reservation_id"
    t.float    "price"
    t.float    "net_price"
    t.boolean  "confirmed"
    t.string   "confirmation_no"
    t.boolean  "paid"
    t.date     "paid_date"
    t.integer  "num_people"
    t.integer  "day",             :default => 0, :null => false
    t.integer  "nights",          :default => 0, :null => false
    t.datetime "mailed_at"
  end

  create_table "trips", :force => true do |t|
    t.string   "registration_id"
    t.datetime "arrival"
    t.datetime "departure"
    t.integer  "total_people"
    t.integer  "num_children"
    t.integer  "num_disabled"
    t.integer  "client_id"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status"
    t.integer  "payment_pct"
    t.text     "payment_details"
    t.string   "arrival_flight"
    t.string   "departure_flight"
    t.date     "confirmation_date"
    t.float    "supplemental_price", :default => 0.0
  end

end
