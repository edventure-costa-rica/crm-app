class Client < ActiveRecord::Base
    has_many :trips, :dependent => :delete_all
    has_many :reservations, :through => :trip

    validates_presence_of :email
    validates_presence_of :family_name
    #validates_format_of :email, :with => /^[\w.]+@[\w.]+$/i,
    #  :message => I18n.t(:invalid_email)

    def to_s
      return Client.human_name if new_record?

      if I18n.locale == :en then
        self.family_name + ' Family'
      else
        'Los ' + self.family_name
      end
    end
end
