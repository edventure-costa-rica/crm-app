class Reservation < ActiveRecord::Base
  include Exportable

  export([
      ['Company', -> { company.name }],
      :services,
      ['Arrival', -> { I18n.l arrival }],
      :pick_up,
      ['Departure', -> { I18n.l departure }],
      :drop_off,
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

  def to_event
    {
        id: id,
        title: company.name,
        allDay: nights > 0,
        start: arrival,
        end: departure + 1,
        type: company.kind,
        model: self
    }
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
    trip.arrival.to_date + day
  end

  def departure
    trip.arrival.to_date + day + nights
  end

  # currency values accept (and drop) dollar signs
  [:net_price,:price].each do |attr|
    define_method "#{attr}=" do |value|
      write_attribute attr, value.to_s.sub(/^\s*\$\s*/, '')
    end
  end

  def after_initialize
    if new_record? and not trip.nil?
      # fill in number of people from trip size
      self.num_people ||= trip.total_people

      if day.nil? and company.hotel? and (hotel = trip.hotels.last)
        self.day = hotel.day + hotel.nights
      end
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
