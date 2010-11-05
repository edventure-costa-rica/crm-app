class Company < ActiveRecord::Base
  has_many :reservations

  validates_presence_of :name, :country
  validates_uniqueness_of :name, :scope => :country

  before_save :proper_website_url

  def to_s; new_record? ? Company.human_name : "#{name} / #{city} #{country}"; end

  def proper_website_url
    return unless self.website?

    self.website = "http://#{website}" unless website =~ /^https?:/
  end
end
