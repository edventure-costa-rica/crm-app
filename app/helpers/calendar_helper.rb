module CalendarHelper
  def all_entries
    @reservations + @departure + @arrival
  end

  def entries_for_date(date=@date)
    entries =
      @reservations.select { |res| res.arrival.to_date == date or res.departure.to_date == date } +
        @departure.select { |trip| trip.departure.to_date == date } +
        @arrival.select { |trip| trip.arrival.to_date == date }

    entries.sort_by { |entry| [entry.client.to_s, entry.is_a?(Trip) ? 0 : 1] }
  end

  def trip_arrival_departure(trip, date=@date)
    if trip.arrival.to_date == date
      :arrival
    else
      :departure
    end
  end

  def trip_flight(trip, date=@date)
    trip.send [trip_arrival_departure(trip, date), :flight].join('_')
  end

end
