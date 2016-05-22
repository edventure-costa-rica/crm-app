module ReservationsHelper

  def reservation_event(res)
    {
        id: res.id,
        title: res.company.name,
        allDay: true,
        start: res.arrival,
        end: res.departure + 1,
        type: res.company.kind,
        update_url: reservation_url(res),
        model: res.as_json(methods: %i(arrival departure))
    }
  end

end
