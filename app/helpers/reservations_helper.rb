module ReservationsHelper

  def reservation_event(res)
    {
        id: res.id,
        title: res.company.name,
        allDay: true,
        start: res.arrival,
        end: res.departure + 1,
        type: res.company.kind,
        update_html: reservation_url(res, format: :html),
        update_json: reservation_url(res, format: :json),
        confirm_url: confirm_reservation_url(res),
        model: res
    }
  end

  def transport_pick_up(res)
    if not res.pick_up.to_s.empty?
      res.pick_up

    else
      trip_pick_up_date(res.trip, res.arrival)
    end
  end

  def trip_pick_up_date(trip, date)
    date = date.to_date

    if trip.arrival.to_date == date
      [trip.arrival_flight, trip.arrival.strftime('%l:%M %P')].compact.join(' ')

    else
      # pick up from the first hotel for the given date
      trip.reservations.
          find_all { |r| r.company.hotel? }.
          detect { |r| date.between?(r.arrival, r.departure) }.
          try(:company).try(:name)
    end
  end

  def transport_drop_off(res)
    if not res.drop_off.to_s.empty?
      res.drop_off

    else
      trip_drop_off_date(res.trip, res.arrival)
    end
  end

  def trip_drop_off_date(trip, date)
    date = date.to_date

    if trip.departure.to_date == date
      [trip.departure_flight, trip.departure.strftime('%l:%M %P')].compact.join(' ')

    else
      # drop off at the last hotel for the given date
      trip.reservations.
          find_all { |r| r.company.hotel? }.to_a.reverse.
          detect { |r| r.arrival == date or date.between?(r.arrival, r.departure) }.
          try(:company).try(:name)
    end
  end
end
