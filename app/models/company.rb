class Company < ActiveRecord::Base
  class << self
    attr_reader :kinds

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

  validates_inclusion_of :kind, :in => Company.kinds
  validates_presence_of :name

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
end
