class Company < ActiveRecord::Base
  include Exportable

  export([
    :name,
    :kind,
    ['Location', ->{ [address, region].compact.map(&:strip).reject(&:empty?).join(', ') }],
    :website,
    :general_contact,
    ['Administrative contact', :admin_contact],
    :reservation_contact,
    ['General Email', ->{ contact_general_email.to_s.clean_email }],
    ['Administrative Email', ->{ contact_admin_email.to_s.clean_email }],
    ['Reservation Email', ->{ contact_reservation_email.to_s.clean_email }]
  ])

  class << self
    attr_reader :kinds, :govt_id_types

    def all_in_region(region_id)
      Company.all :conditions => { :region_id => region_id },
        :order => 'regions.country, regions.name, city, companies.name',
        :include => :region
    end

    def all_for_kind(kind)
      Company.all :conditions => { :kind => kind },
        :order => 'regions.country, regions.name, city, companies.name',
        :include => :region
    end
  end

  @kinds = [
    'hotel',
    'transport',
    'tour',
    'other'
  ]

  @govt_id_types = [
    'cédula_física',
    'cédula_jurídica',
    'pasaporte'
  ]

  validates_inclusion_of :kind, :in => Company.kinds
  validates_presence_of :name

  validates_presence_of :bank_govt_id_type,
    :if => Proc.new { |co| not co.bank_govt_id.blank? }
  validates_inclusion_of :bank_govt_id_type, :in => Company.govt_id_types,
    :if => Proc.new { |co| not co.bank_govt_id_type.blank? }

  has_many :reservations
  belongs_to :region

  before_save :proper_website_url

  def country
    region.country unless region.nil?
  end

  def to_s
    new_record? ?
      Company.human_name :
      "#{name} / #{region}"
  end

  @kinds.each do |k|
    define_method "#{k}?" do
      self.kind == k
    end
  end

  def proper_website_url
    return unless self.website?

    self.website = "http://#{website}" unless website =~ /^https?:/
  end

  %w(general admin reservation).each do |type|
    define_method "#{type}_contact" do
      email = self.send("contact_#{type}_email").to_s.clean_email
      %w(name phone mobile).map do |what|
        self.send("contact_#{type}_#{what}".to_s)
      end.push(email).compact.map(&:strip).reject(&:empty?).join(' ')
    end
  end

  def after_initialize
    if new_record?
      self.kind ||= Company.kinds[0]
    end
  end
end
