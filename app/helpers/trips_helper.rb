module TripsHelper

  def trip_arrival_event(trip)
    {
        id: "#{trip.id}_arrival",
        title: 'Arrival ' + trip.client.family_name,
        start: trip.arrival_date,
        end: trip.arrival_date + 1,
        allDay: true,
        type: :arrival,
        model: trip
    }
  end

  def trip_departure_event(trip)
    {
        id: "#{trip.id}_departure",
        title: 'Departure ' + trip.client.family_name,
        start: trip.departure_date,
        end: trip.departure_date + 1,
        allDay: true,
        type: :departure,
        model: trip
    }
  end
end
