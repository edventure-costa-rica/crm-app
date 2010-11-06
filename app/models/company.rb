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

  validates_inclusion_of :kind, :in => Company.kinds

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

  def proper_website_url
    return unless self.website?

    self.website = "http://#{website}" unless website =~ /^https?:/
  end
end
