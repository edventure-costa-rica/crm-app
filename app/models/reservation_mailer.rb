require 'yaml'

class ReservationMailer < ActionMailer::Base
  attr_reader :config

  def initialize(*args)
    @config = YAML.load_file(File.join(RAILS_ROOT, 'config/mail.yml')) || Hash.new
    super
  end

  def confirmation_email(res, override=Hash.new)
    rcpt_address = override.fetch(:rcpt) do
      res.guess_reservation_email
    end

    from_address = config['from']
    signature    = config['signature']
    content      = override.fetch(:body) do
      { reservation: res,
        trip: res.trip,
        client: res.client,
        company: res.company,
        from: from_address,
        signature: signature
      }
    end


    recipients    rcpt_address
    from          "#{signature} <#{from_address}>"
    bcc           from_address
    content_type  'text/plain'
    subject       "Reservación Fam. #{res.client.family_name}"
    body          content
  end
end
