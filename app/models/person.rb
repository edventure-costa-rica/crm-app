class Person < ActiveRecord::Base
  belongs_to :trip, :touch => true

  validates_presence_of :trip_id
end
