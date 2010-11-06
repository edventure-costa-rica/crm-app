class Company < ActiveRecord::Base
  class << self
    attr_reader :kinds
  end

  @kinds = [
    :hotel,
    :transport,
    :tour,
    :other
  ]

  has_many :reservations
  belongs_to :region
  has_one :country, :through => :region

  validates_inclusion_of :kind, :in => Company.kinds

  before_save :proper_website_url

  def to_s; new_record? ? Company.human_name : "#{name} / #{region}"; end

  def proper_website_url
    return unless self.website?

    self.website = "http://#{website}" unless website =~ /^https?:/
  end
end
