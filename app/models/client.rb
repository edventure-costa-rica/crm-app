class Client < ActiveRecord::Base
  include Exportable

  export([
    :family_name,
    ['Contact name', ->{ [contact_title, contact_name].compact.join(' ') }],
    ['Email', ->{ email.to_s.strip }],
    ['Phone', ->{ phone.to_s.strip }],
    :contact_address
  ])

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

  def self.search(query, options = {})
    condition = [
      "family_name LIKE ? ESCAPE '\\' OR
       contact_name LIKE ? ESCAPE '\\' OR
       email LIKE ? ESCAPE '\\'"]
    condition << query.escape_like + '%'
    condition << query.escape_like + '%'
    condition << '%' + query.escape_like + '%'

    all(options.merge(conditions: condition))
  end
end
