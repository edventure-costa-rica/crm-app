class Region < ActiveRecord::Base
  has_many :companies

  # define all countries as a list
  @countries = [
    'Costa Rica',
    'Panama',
    'Nicaragua',
    'Guatemala',
    'Honduras'
  ]

  # class method reader
  class << self
    attr_reader :countries

    def ordered
      self.all :order => 'country, name'
    end
  end

  validates_uniqueness_of :name, :scope => :country
  validates_inclusion_of :country, :in => @countries

  def to_s
    if name.nil?
      country
    else
      "#{name}, #{country}"
    end
  end
end
