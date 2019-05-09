require 'prawn/measurement_extensions'

class VoucherReport < Prawn::Document
    @@voucher = "#{RAILS_ROOT}/voucher.jpg"

    @@fields = [
        { :width    => 59.52.mm,
          :height   => 8.33.mm,
          :left     => 9.75.mm,
          :bottom   => 66.04.mm,
          :source   => [:client, :family_name],
        },
        { :width    => 21.19.mm,
          :height   => 5.28.mm,
          :left     => 45.48.mm,
          :bottom   => 80.67.mm,
          :source   => [:trip, :registration_id],
        },
        { :width    => 37.19.mm,
          :height   => 5.28.mm,
          :left     => 95.71.mm,
          :bottom   => 80.47.mm,
          :source   => [:confirmation_no],
        },
        { :width    => 34.14.mm,
          :height   => 5.28.mm,
          :left     => 10.97.mm,
          :bottom   => 93.07.mm,
          :source   => [:num_people],
        },
        { :width    => 76.40.mm,
          :height   => 5.28.mm,
          :left     => 53.85.mm,
          :bottom   => 93.07.mm,
          :source   => [:client, :nationality],
        },
        { :width    => 71.32.mm,
          :height   => 6.71.mm,
          :left     => 9.55.mm,
          :bottom   => 105.66.mm,
          :source   => [:company, :name],
        },
        { :width    => 43.89.mm,
          :height   => 5.689.mm,
          :left     => 87.78.mm,
          :bottom   => 105.87.mm,
          :source   => [:company, :country],
        },
        { :width    => 123.14.mm,
          :height   => 11.38.mm,
          :left     => 9.55.mm,
          :bottom   => 120.29.mm,
          :source   => [:services],
        },
        { :width    => 35.80.mm,
          :height   => 5.28.mm,
          :left     => 28.04.mm,
          :bottom   => 137.16.mm,
          :source   => ->(res) { I18n.l res.arrival, format: :voucher },
        },
        { :width    => 35.80.mm,
          :height   => 5.28.mm,
          :left     => 95.61.mm,
          :bottom   => 136.96.mm,
          :source   => ->(res) { I18n.l res.departure, format: :voucher },
        },
        { :width    => 59.13.mm,
          :height   => 14.83.mm,
          :left     => 8.94.mm,
          :bottom   => 151.59.mm,
          :source   => [:pick_up],
        },
        { :width    => 59.13.mm,
          :height   => 14.83.mm,
          :left     => 73.36.mm,
          :bottom   => 151.59.mm,
          :source   => [:drop_off],
        },
        { :width    => 119.89.mm,
          :height   => 11.99.mm,
          :left     => 9.96.mm,
          :bottom   => 175.36.mm,
          :source   => [:notes],
        },
        {
          :width    => 30.0.mm,
          :height   => 15.5.mm,
          :left     => 4.96.mm,
          :bottom   => 192.5.mm,
          :source   => proc { Date.today.iso8601 }
        },
        {
          :width    => 30.0.mm,
          :height   => 15.5.mm,
          :left     => 50.96.mm,
          :bottom   => 192.5.mm,
          :source   => proc { "Maite Salinas" }
        }
    ]

    def self.new(options={})
        options[:margin] = 0
        options[:page_size] = [ 5.5.in, 8.5.in ]
        options[:skip_page_creation] = true

        super(options)
    end

    def add_reservation(reservation)
        start_new_page

        # background image
        image @@voucher, :fit => [ bounds.width, bounds.height ]

        # special field
        orig = fill_color
        fill_color 'ff0000'
        font "Courier" do
            text_box sprintf('V%05d', reservation.id),
                :size  => 17,
                :at    => [108.0.mm, bounds.height - 33.0.mm],
                :style => :bold
        end
        fill_color orig

        # main fields
        @@fields.each do |field|
          str =
            if field[:source].respond_to? :call
              field[:source].call(reservation)
            else
              field[:source].reduce(reservation) { |str, m| str.send m }
            end

            text_box str.to_s,
                :width      => field[:width],
                :height     => field[:height],
                :at         => [ field[:left], bounds.height - field[:bottom] ],
                :overflow   => :shrink_to_fit,
                :align      => :center
        end
    end
end
