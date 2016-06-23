require 'yaml'

class ReservationMailer < ActionMailer::Base
  attr_reader :config

  def initialize(*args)
    @config = YAML.load_file(File.join(RAILS_ROOT, 'config/mail.yml')) || Hash.new
    super
  end

  def confirmation_email(res)
    rcpt = res.guess_reservation_email or
        raise "#{res.company} has no reservation email address"

    recipients    rcpt
    from          config.fetch('from_address', 'do-not-reply@edventure.biz')
    reply_to      config.fetch('reply_to', 'maite@edventure.biz')
    subject       "Reservación para los #{res.client.family_name}"
    body          reservation: res
  end
end
