class Region < ActiveRecord::Base
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
  end

end
