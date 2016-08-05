require 'fileutils'

class Trip < ActiveRecord::Base
  class << self
    attr_reader :statuses
    attr_accessor :ftp_mkdir, :ftp_host, :ftp_root, :ftp_path
  end

  @statuses = [
    'pending',
    'confirmed',
    'canceled'
  ]

  belongs_to :client
  has_many :reservations, dependent: :delete_all, order: 'day ASC'

  after_create :mkdir_ftp

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

  def hotels
    reservations.find(:all, include: :company,
                      conditions: ['companies.kind = ?', 'hotel'])
  end

  def to_s; new_record? ? Trip.human_name : self.registration_id; end

  def ftp_abs_path
    File.join(Trip.ftp_root, ftp_rel_path)
  end

  def ftp_rel_path
    name = [created_at.year, registration_id, client.family_name] * '_'
    File.join(Trip.ftp_path, name)
  end

  def ftp_url
    File.join("ftp://#{Trip.ftp_host}", ftp_rel_path)
  end

  def days
    (departure.to_date - arrival.to_date).to_i
  end

  def arrival_date
    arrival.try(:to_date)
  end

  def departure_date
    departure.try(:to_date)
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

  # override arrival setter to update
  # all reservations with the difference in days
  def arrival=(value)
    unless self.arrival.nil?
      delta = value.to_date - self.arrival_date
      reservations.each do |res|
        res.day += delta
      end
    end

    write_attribute(:arrival, value)
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

  def mkdir_ftp
    if Trip.ftp_mkdir
      logger.info "Creating FTP directory at #{ftp_abs_path}"
      FileUtils.mkdir_p(ftp_abs_path) rescue nil
    else
      logger.info "Not creating FTP directory"
    end
  end

end
