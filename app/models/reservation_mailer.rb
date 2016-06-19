require 'yaml'

class ReservationMailer < ActionMailer::Base
  attr_reader :config

  def initialize(*args)
    super

    @config = YAML.load_file(File.join(RAILS_ROOT, 'config/mail.yml'))
  end

  def confirmation_email(res)
    family = res.client.family_name

    rcpt = res.guess_reservation_email or
        raise "#{res.company} has no reservation email address"

    recipients    rcpt
    from          config['from_address']
    reply_to      config['reply_to']
    subject       "Reservación para los #{family}"
    body          reservation: reservation
  end
end
