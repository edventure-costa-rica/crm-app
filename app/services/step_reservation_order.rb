class StepReservationOrder
  attr_reader :reservation,
              :direction


  # @param direction [Symbol] :earlier or :later
  def initialize(reservation, direction=:later)
    @reservation = reservation
    @direction = direction
  end

  def save!
    raise "Can't move reservation any #{direction}" if succ.nil?

    swap reservation, succ

    Reservation.transaction do
      succ.save!
      reservation.save!
    end
  end

  private

  def dir
    direction == :later ? 1 : -1
  end

  def succ
    @succ ||=
        begin
          hotels = siblings.find(:all,
                                 joins: :company,
                                 conditions: ['companies.kind = ?', 'hotel'],
                                 order: 'day ASC').to_a

          index = dir + hotels.find_index { |r| r.id == reservation.id }
          index >= 0 ? hotels[index] : nil
        end
  end

  def siblings
    reservation.trip.reservations
  end

  def swap(a, b)
    first, last = a.day < b.day ? [a, b] : [b, a]
    final = last.day + last.nights
    last.day = first.day
    first.day = final - first.nights
  end
end
