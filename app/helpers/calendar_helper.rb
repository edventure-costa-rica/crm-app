module CalendarHelper
  def all_entries
    @reservations + @departure + @arrival
  end

  def entries_for_date(date=@date)
    entries =
      @reservations.select { |res| res.arrival <= date and res.departure >= date } +
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

  def res_arrival_departure(res, date=@date)
    if res.arrival.to_date == date
      :arrival
    elsif res.departure.to_date == date
      :departure
    end
  end

  def trip_flight(trip, date=@date)
    trip.send [trip_arrival_departure(trip, date), :flight].join('_')
  end

  def entry_arrival_departure(entry, date)
    if entry.is_a? Trip
      trip_arrival_departure(entry, date)
    else
      res_arrival_departure(entry, date)
    end
  end

  def entry_transfer_string(entry, transfer)
    return unless transfer
    return transfer.to_s.humanize if entry.is_a? Trip

    if entry.company.hotel?
      transfer.to_s.humanize
    else
      transfer == :arrival ? 'Pick Up' : 'Drop Off'
    end
  end

end
