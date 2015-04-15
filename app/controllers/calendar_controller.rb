require 'date'

class CalendarController < ApplicationController
  before_filter :set_date

  def day
    @reservations = Reservation.all(
      conditions: ['reservations.arrival = ? OR reservations.departure = ?', @date, @date],
      joins: [:company, :trip],
      include: [:company, :trip],
      order: 'reservations.arrival ASC, reservations.departure ASC, trips.id ASC, companies.kind ASC'
    )

    @arrival = Trip.all(conditions: ['DATE(arrival) = ?', @date], order: :arrival)
    @departure = Trip.all(conditions: ['DATE(departure) = ?', @date], order: :departure)
  end

  def week
    range_start = @date.beginning_of_week.to_date
    range_end = @date.end_of_week.to_date

    find_entries(range_start, range_end)

    @date = range_start
    @range = range_start .. range_end
  end

  def month
  end

  def year
  end

  def set_date
    if params.has_key? :date
      @date = Date.parse(params[:date])
    else
      @date = Date.today
    end
  end

  def find_entries(range_start, range_end)
    @reservations = Reservation.all(
      conditions: [
        '(reservations.arrival >= ? AND reservations.arrival <= ?) OR ' +
          '(reservations.departure >= ? AND reservations.departure <= ?)',
        range_start, range_end, range_start, range_end
      ],
      joins: [:company, :trip],
      include: [:company, :trip],
      order: 'reservations.arrival ASC, reservations.departure ASC, trips.id ASC, companies.kind ASC'
    )

    @arrival = Trip.all(
      conditions: ['DATE(arrival) >= ? AND DATE(arrival) <= ?', range_start, range_end],
      order: :arrival
    )

    @departure = Trip.all(
      conditions: ['DATE(departure) >= ? AND DATE(departure) <= ?', range_start, range_end],
      order: :departure
    )
  end

end
