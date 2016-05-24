require 'csv'

class ReservationsController < ApplicationController
  # GET /companies/1/reservations
  def index
    @reservations = Reservation.all(
      :conditions => { :company_id => params[:company_id] },
      :order      => 'day DESC'
    )

    @company = Company.find(params[:company_id])

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
      case params[:next]
      when 'confirmed'
        confirmed_trip_reservations_url(@trip)
      when 'unconfirmed'
        unconfirmed_reservations_url
      when 'unpaid'
        unpaid_reservations_url
      else
        pending_trip_reservations_url(@trip)
      end

    respond_to do |format|
      if @reservation.update_attributes(reservation_params)
        format.html { redirect_to(destination, :notice => 'Reservation was successfully updated.') }
        format.json { render json: @reservation }
      else
        flash[:params] = params
        flash[:notice] = @reservation.errors.full_messages.join(', ')
        format.html { redirect_to destination }
        format.json { render json: {errors: @reservation.errors} }
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

  def move
    res = Reservation.find(params[:id])

    unless res.company.hotel?
      flash[:notice] = "Unable to move #{res.company.kind} reservations"
      redirect_to pending_trip_reservations_url(res.trip)
      return
    end

    begin
      direction = params[:later] ? :later : :earlier
      StepReservationOrder.new(res, direction).save!
    rescue => ex
      flash[:notice] = ex.to_s
      logger.warn ex.backtrace.join("\n\t")
    end

    redirect_to pending_trip_reservations_url(res.trip)
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
      :order      => 'day ASC, id ASC'

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
    @reservations = @trip.reservations.all(order: 'day ASC, id ASC')
  end

  def events
    trip = Trip.find(params[:trip_id])
    start = Chronic.parse(params[:start]) - params[:timezone].to_i
    end_ = Chronic.parse(params[:end]) - params[:timezone].to_i

    start_day = start.to_date - trip.arrival.to_date
    end_day = end_.to_date - trip.arrival.to_date

    events = trip.reservations.find(:all, joins: :company, conditions:
        [ 'day > ? OR (day + nights) < ?', start_day.to_i, end_day.to_i ]
    )

    render json: events.map { |r| @template.reservation_event(r) }
  end

  def confirmed
    @trip = Trip.find(params[:trip_id])
    @reservations = @trip.reservations.all(order: 'day ASC, id ASC')
  end

  # GET /reservations/unconfirmed
  def unconfirmed
    conditions = {confirmed: false, paid: false}
    conditions[:kind] = params[:kind] if params.has_key? :kind
    limit, offset = page_to_limit_offset

    @reservations =
        Reservation.find(:all,
                         joins: [:company, :trip],
                         conditions: conditions,
                         limit: limit,
                         offset: offset,
                         order: 'updated_at DESC, day ASC')
  end

  # GET /reservations/unpaid
  def unpaid
    conditions = {confirmed: true, paid: false}
    conditions[:kind] = params[:kind] if params.has_key? :kind
    limit, offset = page_to_limit_offset

    @reservations =
        Reservation.find(:all,
                         joins: [:company, :trip],
                         conditions: conditions,
                         limit: limit,
                         offset: offset,
                         order: 'updated_at DESC, day ASC')
  end

  def export
    @trip = Trip.find(params[:trip_id])

    name = @trip.registration_id + '.csv'

    header = CSV.generate_line(Reservation.export_header, encoding: 'UTF-8')

    csv = @trip.reservations.map do |res|
      CSV.generate_line(res.export, encoding: 'UTF-8')
    end

    respond_to do |format|
      format.csv { send_data header + csv.join, filename: name }
    end
  end

  def paste
    paste_params = reservation_paste_params

    trip = Trip.find(params[:trip_id])
    parser = ExcelParser.new(paste_params[:paste])

    trip.reservations = parser.reservations(trip)

    if parser.error?
      flash[:notice] = parser.errors.first

    elsif trip.save
      flash[:notice] = "Created #{trip.reservations.count} reservations OK"

    else
      flash[:notice] = trip.errors.full_messages.join(", ")
    end

    redirect_to pending_trip_reservations_url(trip)
  end

  private

  def reservation_params
    params[:reservation]
  end

  def reservation_paste_params
    params[:reservations]
  end

  def page_to_limit_offset(limit=25)
    @page = [params.fetch(:page, 1), 1].map(&:to_i).max
    offset = (@page - 1) * limit

    [limit, offset]
  end
end
