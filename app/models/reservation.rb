class Reservation < ActiveRecord::Base
  belongs_to :company
  belongs_to :trip

  has_one :client, :through => :trip

  validates_associated :trip, :company
  validates_numericality_of :price, :allow_nil => true
  validate :arrival_precedes_departure

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
    pickup_location.to_s + "\n" +
    arrival.strftime('%l:%M %P')
  end

  def departure_place_and_time
    dropoff_location.to_s + "\n" +
    departure.strftime('%l:%M %P')
  end

private
  def arrival_precedes_departure
    errors.add :departure, I18n.t(:arrival_precedes_departure) unless
      self.departure > self.arrival
  end
end
