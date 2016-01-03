class Trip < ActiveRecord::Base
  class << self
    attr_reader :statuses
  end

  @statuses = [
    'pending',
    'confirmed',
    'canceled'
  ]

  belongs_to :client
  has_many :reservations, :dependent => :delete_all,
    :order => 'arrival ASC, departure ASC'

  before_validation_on_create :generate_default_values

  validates_presence_of :arrival, :departure

  validates_numericality_of :total_people,
    :greater_than => 0, :only_integer => true
  
  validates_numericality_of :num_children, :num_disabled,
    :allow_nil => true

  validates_numericality_of :payment_pct, 
    :only_integer => true, :allow_nil => true

  validates_inclusion_of :status, :in => Trip.statuses

  @statuses.each do |status|
    define_method(status + '?') do
      self.status == status
    end
  end

  def to_s; new_record? ? Trip.human_name : self.registration_id; end

  def nights
    (departure.to_date - arrival.to_date).to_i
  end

  def arrival_date
    arrival.to_date
  end

  def departure_date
    departure.to_date
  end

  @statuses.each do |s|
    define_method "#{s}?" do
      self.status == s
    end
  end

  def children?
    num_children > 0
  end

  def disabled?
    num_disabled > 0
  end

  def pax
    [total_people, num_children, num_disabled].join('/').gsub(/\/0(\/0)?$/, '')
  end

  def total_rack_price
    reservations.to_a.sum { |r| r.price.to_f }
  end

  def total_net_price
    reservations.to_a.sum { |r| r.net_price.to_f }
  end

  def generate_default_values
    self.num_children = 0 if self.num_children.nil?
    self.num_disabled = 0 if self.num_disabled.nil?
    self.payment_pct  = 0 if self.payment_pct.nil?
    self.status = 'pending' if self.status.nil?

    unless self.registration_id
      reg = 'F' + self.client.family_name[0,3].upcase
      reg += format '%02d%02d%04d',
        self.arrival.day,
        self.arrival.month,
        self.arrival.year

      self.registration_id = reg
    end
  end

end
