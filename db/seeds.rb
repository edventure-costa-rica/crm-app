# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)

# single-region countries
['Nicaragua', 'Guatemala', 'Honduras'].each do |r|
  Region.create :country => r
end

# panama
['Panama City', 'Pacific', 'Carribean', 'Boquete'].each do |r|
  Region.create :name => r, :country => 'Panama'
end

# costa rica
['San José', 'Central Costa Rica', 'North Costa Rica', 'North Pacific',
 'South Pacific', 'Carribean', 'Tortuguero', 'Sarapiqui', 'Arenal', 'Monteverde'].
each do |r|
  Region.create :name => r, :country => 'Costa Rica'
end


# import from the hotel CSV
require 'csv'
CSV.open 'contrib/hotels.csv', 'r' do |row|
  # ...
end