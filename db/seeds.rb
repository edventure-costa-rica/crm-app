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
@fields = {
#  :country => 1,
  :package => 2,
  :name => 4,
  :city => 5,
  :package_length => 6,
  :contact_general_name => 9,
  :contact_general_email => 10,
  :website => 11,
  :contact_general_phone => 12,
  :contact_general_mobile => 13,
  :bank_provider => 15,
  :bank_name => 16,
  :bank_address => 17,
  :bank_aba => 18,
  :bank_swift => 19,
  :bank_account => 20,
  :bank_beneficiary => 21,
  :bank_client_account => 22,
  :bank_govt_id => 23
}

# cache regions
@regions = {}
['Costa Rica', 'Panama', 'Nicaragua', 'Honduras', 'Guatemala'].each do |c|
  id = c.gsub(/\s/, '').downcase
  @regions[id] = Region.find_by_country c, :first
end

@row = 0
CSV.open 'contrib/hotels.csv', 'r' do |row|
  @row += 1

  # two lines of headers... brilliant
  next if @row < 3

  # tons of blank lines to skip
  next if row[1].blank?
  country = row[1].gsub(/\s/,'').downcase

  unless @regions.has_key?(country)
    puts "Skipping row #{@row} with invalid country '#{country}'"
    next
  end

  attribs = { :kind => 'hotel', :region => @regions[country] }
  @fields.each_pair { |field, column| attribs[field] = row[column] }

  # i don't really understand why she lists hotels with no name
  if attribs[:name] !~ /[A-Za-z]/
    puts "Skipping unnamed hotel at row #{@row}"
    next
  end

  begin
    Company.create(attribs)
  rescue => ex
    puts "Failed to create hotel at row #{@row}: #{ex}"
  end
end

puts "Created #{@row} hotels"