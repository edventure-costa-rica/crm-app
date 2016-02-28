class Reservation < ActiveRecord::Base
  include Exportable

  export([
      ['Company', -> { company.name }],
      :services,
      ['Arrival Date', -> { I18n.l arrival }],
      :arrival_time,
      :pickup_location,
      ['Departure Date', -> { I18n.l departure }],
      :departure_time,
      :dropoff_location,
      :net_price,
      :price,
      :confirmed,
      :paid,
      :notes
  ])

  belongs_to :company
  belongs_to :trip

  has_one :client, :through => :trip
  has_one :region, :through => :company

  validates_presence_of :company
  validates_associated :trip, :company
  validates_numericality_of :price, :allow_nil => true

  after_save :confirm_trip
  after_destroy :confirm_trip

  def to_s
    return Reservation.human_name if new_record?

    company.name + " / " +
      I18n.localize(arrival.to_date, :format => :short)
  end

  def city
    self.company.city if self.company
  end

  def pax
    num_people
  end

  def profit
    price.to_f - net_price.to_f
  end

  def arrival
    trip.arrival + day
  end

  def departure
    trip.arrival + day + nights
  end

  # currency values accept (and drop) dollar signs
  [:net_price,:price].each do |attr|
    define_method "#{attr}=" do |value|
      write_attribute attr, value.sub(/^\s*\$\s*/, '')
    end
  end

  def after_initialize
    if new_record? and not trip.nil?
      # fill in number of people from trip size
      self.num_people ||= trip.total_people
    end
  end

  def confirm_trip
    if %w(pending confirmed).include? self.trip.status
      pending = {confirmed: false, paid: false}

      if trip.reservations.empty? or trip.reservations.exists? pending
        self.trip.status = 'pending'
      else
        self.trip.status = 'confirmed'
      end

      self.trip.touch
    end
  end
end
