require 'yaml'

class ReservationMailer < ActionMailer::Base
  attr_reader :config

  def initialize(*args)
    @config = YAML.load_file(File.join(RAILS_ROOT, 'config/mail.yml')) || Hash.new
    super
  end

  def confirmation_email(res)
    rcpt_address = res.guess_reservation_email or
        raise "#{res.company} has no reservation email address"

    from_address = config['from']

    recipients    rcpt_address
    from          from_address
    subject       "Reservación para los #{res.client.family_name}"
    body          reservation: res,
                  client: res.client,
                  company: res.company,
                  from: from_address,
                  signature: config['signature']
  end
end
