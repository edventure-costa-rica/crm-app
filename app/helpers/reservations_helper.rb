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
    trip = res.trip

    if not res.pick_up.to_s.empty?
      res.pick_up

    elsif trip.arrival == res.arrival
      trip.arrival_flight

    else
      trip.reservations.
          detect { |r| r.company.hotel? and r.departure == res.arrival }.
          try(:company).try(:name)
    end
  end

  def transport_drop_off(res)
    trip = res.trip

    if not res.drop_off.to_s.empty?
      res.drop_off

    elsif trip.departure == res.arrival
      trip.departure_flight

    else
      trip.reservations.
          detect { |r| r.company.hotel? and r.arrival == res.arrival }.
          try(:company).try(:name)
    end
  end
end
