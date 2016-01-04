require 'csv'

class ReservationsController < ApplicationController
  # GET /reservations
  # GET /reservations.xml
  def index
    @client = Client.find(params[:client_id]) if params[:client_id]

    if params[:trip_id] then
      @reservations = Reservation.all \
        :conditions => { :trip_id => params[:trip_id] },
        :order      => 'arrival ASC'

      @trip = Trip.find(params[:trip_id])

    elsif params[:company_id] then
      @reservations = Reservation.all \
        :conditions => { :company_id => params[:company_id] },
        :order      => 'arrival DESC'

      @company = Company.find(params[:company_id])

    else
      logger.warn "Tried to list reservations without context\n"
      @reservations = Reservation.all :order => 'arrival DESC'

    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @reservations }
    end
  end

  # POST /trip/1/reservation
  def create
    @trip = Trip.find(params[:trip_id])
    @reservation = @trip.reservations.build(reservation_params)

    respond_to do |format|
      if @reservation.save
        flash[:kind] = @reservation.company.kind
        format.html { redirect_to(pending_trip_reservations_url(@trip), :notice => 'Reservation was successfully created.') }
      else
        flash[:kind] = @reservation.company.kind rescue nil
        flash[:params] = params
        flash[:notice] = @reservation.errors.full_messages.join(', ')
        format.html { redirect_to pending_trip_reservations_url(@trip) }
      end
    end
  end

  # PUT /reservations/1
  # PUT /reservations/1.xml
  def update
    @reservation = Reservation.find(params[:id])
    @trip = @reservation.trip

    destination =
      if params[:next] == 'confirmed'
        confirmed_trip_reservations_url(@trip)
      else
        pending_trip_reservations_url(@trip)
      end

    respond_to do |format|
      if @reservation.update_attributes(reservation_params)
        format.html { redirect_to(destination, :notice => 'Reservation was successfully updated.') }
      else
        flash[:params] = params
        flash[:notice] = @reservation.errors.full_messages.join(', ')
        format.html { redirect_to destination }
      end
    end
  end

  # DELETE /reservations/1
  # DELETE /reservations/1.xml
  def destroy
    @reservation = Reservation.find(params[:id])
    @trip = @reservation.trip

    @reservation.destroy

    respond_to do |format|
      format.html { redirect_to pending_trip_reservations_url(@trip),
                                notice: 'Reservation deleted OK' }
    end
  end

  # GET /clients/1/trips/1/reservations/1/voucher
  def voucher
    @reservation = Reservation.find(params[:id])

    voucher = VoucherReport.new
    voucher.add_reservation @reservation

    respond_to do |format|
      format.pdf do 
        send_data voucher.render,
          :filename => "voucher-#{params[:id]}.pdf",
          :type     => 'application/pdf'
      end
    end
  end

  def vouchers
    @trip = Trip.find params[:trip_id]
    @reservations = Reservation.all \
      :conditions => { :trip_id => @trip.id },
      :order      => 'arrival ASC'

    vouchers = VoucherReport.new
    @reservations.each { |r| vouchers.add_reservation r }

    respond_to do |format|
      format.pdf do 
        send_data vouchers.render,
          :filename => "#{@trip.registration_id}.pdf",
          :type     => 'application/pdf'
      end
    end
  end

  # GET /trips/:trip_id/reservations/pending
  def pending
    @trip = Trip.find(params[:trip_id])
    @reservations = @trip.reservations.all(order: 'arrival DESC')
  end

  def confirmed
    @trip = Trip.find(params[:trip_id])
    @reservations = @trip.reservations.all(order: 'arrival DESC')
  end

  # GET /reservations/unconfirmed
  def unconfirmed
    conditions = {confirmed: false, paid: false}
    conditions[:kind] = params[:kind] if params.has_key? :kind
    @reservations = Reservation.find(:all, conditions: conditions, order: 'arrival DESC')
  end

  # GET /reservations/unpaid
  def unpaid
    conditions = {confirmed: true, paid: false}
    conditions[:kind] = params[:kind] if params.has_key? :kind
    @reservations = Reservation.find(:all, conditions: conditions, order: 'arrival DESC')
  end

  def export
    @trip = Trip.find(params[:trip_id])

    name = @trip.registration_id + '.csv'

    csv = @trip.reservations.map do |res|
      CSV.generate_line res.export, encoding: 'UTF-8'
    end

    respond_to do |format|
      format.csv { send_data csv.join("\r\n"), filename: name }
    end
  end

  private

  def reservation_params
    params[:reservation].tap do |input|
      arrival = Chronic.parse input.delete(:arrival_date_time)
      departure = Chronic.parse input.delete(:departure_date_time)

      if arrival
        input[:arrival] = arrival.to_date
        input[:arrival_time] = arrival.strftime('%l %P')
      end

      if departure
        input[:departure] = departure.to_date
        input[:departure_time] = departure.strftime('%l %P')
      end
    end
  end
end
