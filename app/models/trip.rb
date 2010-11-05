class Trip < ActiveRecord::Base
  belongs_to :client
  has_many :reservations, :dependent => :delete_all

  before_save :generate_default_values

  validates_numericality_of :total_people, :greater_than => 0, :only_integer => true

  validates_numericality_of :num_children, :num_disabled, :allow_nil => true

  def to_s; new_record? ? Trip.human_name : self.registration_id; end

protected
  def generate_default_values
    self.num_children = 0 if self.num_children.nil?
    self.num_disabled = 0 if self.num_disabled.nil?

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
