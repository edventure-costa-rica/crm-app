class CalendarController < ApplicationController
  def view
    reservation_range
    render_calendar
  end

  def transfers
    @companies = Company.all(conditions: {kind: 'transport'})

    select_company, company =
      if params.has_key? :company_id
        @company = Company.find(params[:company_id])
        ['AND companies.id = ?', @company]
      else
        @company = nil
      end

    reservation_range(
      'companies.kind = ? AND reservations.services LIKE ? ' + select_company.to_s,
      'transport', '%transfer%', *[company].compact

    ).sort_by! { |r| [r.arrival, r.services] }

    render_calendar
  end

  def company
    @company = Company.find(params[:id])
    reservation_range('companies.id = ?', @company.id)

    render_calendar
  end

  private

  def render_calendar
    respond_to do |format|
      format.html
      format.json { render json: @reservations.map { |r| @template.reservation_event(r) } }
    end
  end

  def reservation_range(*conditions)
    start_time = params[:start] || Time.now.beginning_of_month
    end_time   = params[:end]   || Chronic.parse(start_time.to_s).next_month
    timezone   = params[:timezone].to_i || 360 # costa rica

    @start_at, @end_at =
      [ Chronic.parse(start_time.to_s) - (timezone * 60),
        Chronic.parse(end_time.to_s) - (timezone * 60)
      ].map(&:to_date)

    joins = [:company, {trip: :client}]

    @reservations = Reservation.all(joins: joins, conditions: [
      [ "reservations.confirmed = ?",
        "(date(trips.arrival, '+' || reservations.day || ' days') >= ?",
        "date(trips.arrival, '+' || (reservations.day + reservations.nights) || ' days') < ?)",
        conditions.shift
      ].compact.join(' AND '),
      true,
      @start_at,
      @end_at,
      *conditions
    ])

    @reservations.sort_by! { |r| [r.arrival, r.client.family_name] }
  end
end
