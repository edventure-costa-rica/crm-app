class CalendarController < ApplicationController
  def transfers
  end

  def company
  end

  def reservation_range
    start_time = params[:start] || Time.now.beginning_of_month
    end_time   = params[:end]   || Time.now.beginning_of_month.next_month
    timezone   = params[:timezone].to_i || 360 # costa rica

    @reservations = Reservation.find(:all, joins: :trip, conditions: [
      "date(trips.arrival, '+' || day || ' days') > ? " +
        "OR date(trips.arrival, '+' || (day + nights) || ' days') < ?",
      start_time.to_date - timezone, end_time - timezone
    ])
  end
end
