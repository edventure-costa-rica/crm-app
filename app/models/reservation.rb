class Reservation < ActiveRecord::Base
  belongs_to :company
  belongs_to :trip

  has_one :client, :through => :trip

  validates_associated :trip, :company
  validates_numericality_of :price, :allow_nil => true

  def region
    company.region unless company.nil?
  end

  def region_id
    company.region.id unless company.nil?
  end

  validate do |res|
    res.send :arrival_precedes_departure
    res.send :within_trip_dates
  end

  def to_s
    return Reservation.human_name if new_record?

    company.name + " / " +
      I18n.localize(arrival.to_date, :format => :short)
  end

  def city
    self.company.city if self.company
  end

  def arrival_date
    I18n.localize arrival.to_date, :format => :voucher
  end

  def departure_date
    I18n.localize departure.to_date, :format => :voucher
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

private
  def arrival_precedes_departure
    errors.add :departure, I18n.t(:arrival_precedes_departure) unless
      self.departure >= self.arrival
  end

  def within_trip_dates
    errors.add :arrival, I18n.t(:arrival_before_trip) unless
      self.arrival >= self.trip.arrival.to_date
    errors.add :arrival, I18n.t(:arrival_after_trip) unless
      self.arrival <= self.trip.departure.to_date
    errors.add :arrival, I18n.t(:departure_before_trip) unless
      self.departure >= self.trip.arrival.to_date
    errors.add :arrival, I18n.t(:departure_after_trip) unless
      self.departure <= self.trip.departure.to_date
  end
end
