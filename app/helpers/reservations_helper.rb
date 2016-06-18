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

end
