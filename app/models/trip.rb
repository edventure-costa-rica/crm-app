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

  before_save :generate_default_values

  validates_numericality_of :total_people,
    :greater_than => 0, :only_integer => true
  
  validates_numericality_of :num_children, :num_disabled,
    :allow_nil => true

  validates_numericality_of :payment_pct, 
    :only_integer => true, :allow_nil => true

  validates_inclusion_of :status, :in => Trip.statuses

  def to_s; new_record? ? Trip.human_name : self.registration_id; end

  def nights
    (departure.to_date - arrival.to_date).to_i
  end

  @statuses.each do |s|
    define_method "#{s}?" do
      self.status == s
    end
  end

protected
  def generate_default_values
    self.num_children = 0 if self.num_children.nil?
    self.num_disabled = 0 if self.num_disabled.nil?
    self.payment_pct  = 0 if self.payment_pct.nil?

    unless self.registration_id
      reg = 'F' + self.client.family_name[0,1].upcase + 'X'
      reg += format '%02d%02d%04d',
        self.arrival.day,
        self.arrival.month,
        self.arrival.year

      self.registration_id = reg
    end
  end
end
