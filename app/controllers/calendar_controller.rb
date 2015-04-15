require 'date'

class CalendarController < ApplicationController
  before_filter :set_date

  def day
    @reservations = Reservation.all(
      conditions: ['reservations.arrival = ? OR reservations.departure = ?', @date, @date],
      joins: [:company, :trip],
      include: [:company, :trip],
      order: 'trips.id ASC, companies.kind ASC, reservations.arrival ASC, reservations.departure ASC'
    )

    @arrival = Trip.all(conditions: ['DATE(arrival) = ?', @date], order: :arrival)
    @departure = Trip.all(conditions: ['DATE(departure) = ?', @date], order: :departure)
  end

  def week
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

end
