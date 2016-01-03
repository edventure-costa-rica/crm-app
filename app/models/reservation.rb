class Reservation < ActiveRecord::Base
  belongs_to :company
  belongs_to :trip

  has_one :client, :through => :trip
  has_one :region, :through => :company

  validates_presence_of :company
  validates_associated :trip, :company
  validates_numericality_of :price, :allow_nil => true

  validate do |res|
    res.send :arrival_precedes_departure
    res.send :within_trip_dates
  end

  after_save :confirm_trip
  after_destroy :confirm_trip

  def next_on_trip
    return unless trip

    trip.reservations.find :first, :order => 'arrival ASC', :conditions =>
      [ 'arrival > ?', self.arrival ]
  end

  def prev_on_trip
    return unless trip

    trip.reservations.find :first, :order => 'arrival ASC', :conditions =>
      [ 'arrival < ?', self.arrival ]
  end

  def to_s
    return Reservation.human_name if new_record?

    company.name + " / " +
      I18n.localize(arrival.to_date, :format => :short)
  end

  def region_id
    company.region.id unless company.nil?
  end

  def city
    self.company.city if self.company
  end

  def nights
    (departure - arrival).to_i
  end

  def arrival_date_str
    I18n.localize arrival.to_date, :format => :voucher
  end

  def departure_date_str
    I18n.localize departure.to_date, :format => :voucher
  end

  def pax
    num_people
  end

  def pickup
    date = arrival ? I18n.localize(arrival.to_date, format: :short) : nil
    time = arrival_time
    place = pickup_location

    [date, time, place].compact.join(' ')
  end

  def dropoff
    date = departure ? I18n.localize(departure.to_date, format: :short) : nil
    time = departure_time
    place = dropoff_location

    [date, time, place].compact.join(' ')
  end

  def arrival_place_and_time
    [ pickup_location, arrival_time ].
      select { |e| not e.nil? }.
      map { |e| e.to_s }.
      join "\n"
  end

  def departure_place_and_time
    [ dropoff_location, departure_time ].
      select { |e| not e.nil? }.
      map { |e| e.to_s }.
      join "\n"
  end

  # currency values accept (and drop) dollar signs
  [:net_price,:price].each do |attr|
    define_method "#{attr}=" do |value|
      write_attribute attr, value.sub(/^\s*\$\s*/, '')
    end
  end

  def arrival_precedes_departure
    if self.arrival and self.departure
      errors.add :departure, I18n.t(:arrival_precedes_departure) unless
        self.departure >= self.arrival
    end
  end

  def within_trip_dates
    if self.arrival
      errors.add :arrival, I18n.t(:arrival_before_trip) unless
        self.arrival >= self.trip.arrival.to_date
      errors.add :arrival, I18n.t(:arrival_after_trip) unless
        self.arrival <= self.trip.departure.to_date
    end

    if self.departure
      errors.add :departure, I18n.t(:departure_before_trip) unless
        self.departure >= self.trip.arrival.to_date
      errors.add :departure, I18n.t(:departure_after_trip) unless
        self.departure <= self.trip.departure.to_date
    end
  end

  def after_initialize
    if new_record? and not trip.nil?
      # fill in number of people from trip size
      self.num_people ||= trip.total_people

      # use the last reservation (or trip) for default arrival
      self.arrival ||= trip.reservations.empty? ?
        trip.arrival : trip.reservations.last.departure

      # use the arrival date for this departure if its the first
      self.departure ||= trip.reservations.empty? ?
        trip.arrival : trip.reservations.last.departure
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
