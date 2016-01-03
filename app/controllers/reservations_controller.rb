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

    respond_to do |format|
      if @reservation.update_attributes(reservation_params)
        format.html { redirect_to(pending_trip_url(@trip), :notice => 'Reservation was successfully updated.') }
      else
        flash[:params] = params
        flash[:notice] = @reservation.errors.full_messages.join(', ')
        format.html { redirect_to pending_trip_url(@trip) }
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

  def pay
    @reservation = Reservation.find params[:id]

    render :layout => 'print'
  end

  def pays
    @reservations = Reservation.find :all,
      :conditions => { :trip_id => params[:trip_id] },
      :order      => 'paid_date ASC, arrival ASC'

    render :layout => 'print'
  end

  def weekly_payments
    # next sunday 
    @week_ending = Date.today
    @week_ending += 1 while (@week_ending.wday != 0)
    @week_ending += 7.days

    @reservations = Reservation.find :all,
      :include    => [:trip],
      :conditions => ['NOT paid AND paid_date <= ? AND ' + 
                      'trip_id IS NOT NULL AND trips.departure >= ?', @week_ending, Date.today],
      :order      => 'paid_date ASC'

    respond_to do |format|
      format.html { render :layout => 'print', :action => 'pays' }
    end
  end

  def yearly_payments
    if params[:year].nil? then 
      @year = Date.today.year 
    else 
      @year = params[:year].to_i
    end

    @weeks = []
    (1..52).each do |week|
      data = { :week => week }
      data[:week_start] = Date.commercial(@year, week, 1)
      data[:week_end] = Date.commercial(@year, week, 7)
      cond = { 
        :paid      => true,
        :paid_date => data[:week_start] .. data[:week_end]
      }
      data[:net_price] = Reservation.sum :net_price, :conditions => cond
      data[:price] = Reservation.sum :price, :conditions => cond
      @weeks << data
    end
  end

  # GET /trips/:trip_id/reservations/pending
  def pending
    @trip = Trip.find(params[:trip_id])
    @reservations = @trip.reservations
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
