require 'date'

class CalendarController < ApplicationController
  before_filter :set_date

  def day
    find_entries(@date, @date)
  end

  def week
    range_start = @date.beginning_of_week.to_date
    range_end = @date.end_of_week.to_date

    find_entries(range_start, range_end)

    @date = range_start
    @range = range_start .. range_end
  end

  def month
    range_start = @date.beginning_of_month.to_date
    range_end = @date.end_of_month.to_date

    find_entries(range_start, range_end)

    @date = range_start
    @range = range_start .. range_end
  end

  def year
    range_start = @date.beginning_of_year.to_date
    range_end = @date.end_of_year.to_date

    find_entries(range_start, range_end)

    @date = range_start
    @range = range_start .. range_end
  end

  def set_date
    if params.has_key? :date
      @date = Date.parse(params[:date])
    else
      @date = Date.today
    end
  end

  def find_entries(range_start, range_end)
    @reservations = (range_start..range_end).flat_map do |date|
      Reservation.all(
        conditions: [
          '(arrival <= ? AND departure >= ?)', date, date
        ]
      )
    end.to_a.uniq

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
