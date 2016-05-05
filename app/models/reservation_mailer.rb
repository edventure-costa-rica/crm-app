require 'yaml'

class ReservationMailer < ActionMailer::Base
  attr_reader :config

  def initialize(*args)
    super

    @config = YAML.load_file(File.join(RAILS_ROOT, 'config/mail.yml'))
  end

  def confirmation_email(res)
    company = res.company
    family = res.client.family_name

    rcpt = [:reservation_email, :general_email, :admin_email].
      map { |method| company.send method }
      compact.map(&:clean_email).reject(&:empty?).first

    raise "#{company} has no email address" unless rcpt

    recipients    rcpt
    from          config['from_address']
    subject       "Reservación para los #{family}"
    body          reservation: reservation
  end
end
