class CalendarController < ApplicationController
  def view
    reservation_range
    render_calendar
  end

  def transfers
    trip_range
    reservation_range(
      'companies.kind = ? AND reservations.services LIKE ?',
      'transport', '%transfer%'
    )

    render_calendar
  end

  def company
    @company = Company.find(params[:id])
    reservation_range('companies.id = ?', @company.id)

    render_calendar
  end

  private

  def render_calendar(html=true)
    respond_to do |format|
      format.html if html
      format.json { render json: @reservations.map { |r| @template.reservation_event(r) } }
    end
  end

  def trip_range
    start_time = params[:start] || Time.now.beginning_of_month
    end_time   = params[:end]   || Time.now.beginning_of_month.next_month
    timezone   = params[:timezone].to_i || 360 # costa rica

    start_at, end_at =
      Chronic.parse(start_time.to_s) - (timezone * 60),
        Chronic.parse(end_time.to_s) - (timezone * 60)

    @trips = Trip.all(conditions: [
      "status = ? AND ((arrival > ? AND arrival < ?) OR " +
        "(departure > ? AND departure < ?))",
      'confirmed', start_at, end_at, start_at, end_at
    ])
  end

  def reservation_range(*conditions)
    start_time = params[:start] || Time.now.beginning_of_month
    end_time   = params[:end]   || Time.now.beginning_of_month.next_month
    timezone   = params[:timezone].to_i || 360 # costa rica

    start_at, end_at =
      Chronic.parse(start_time.to_s) - (timezone * 60),
        Chronic.parse(end_time.to_s) - (timezone * 60)

    joins = [:company, {trip: :client}]

    @reservations = Reservation.all(joins: joins, conditions: [
      [ "reservations.confirmed = ? AND " +
        "(date(trips.arrival, '+' || reservations.day || ' days') > ? " +
        "OR date(trips.arrival, '+' || (reservations.day + reservations.nights) || ' days') < ?)",
        conditions.shift
      ].compact.join(' AND '),
      true,
      start_at,
      end_at,
      *conditions
    ])

    @reservations.sort_by! { |r| [r.arrival, r.client.family_name] }
  end
end
