class ReservationsController < ApplicationController
  # methods for inline editing on the index page
  in_place_collection_edit_for :reservation, :confirmed do
    [ [true,  I18n.t(:true)],
      [false, I18n.t(:false)] ]
  end

  in_place_collection_edit_for :reservation, :paid do
    [ [true,  I18n.t(:true)],
      [false, I18n.t(:false)] ]
  end

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

  # GET /reservations/1
  # GET /reservations/1.xml
  def show
    @reservation = Reservation.find(params[:id])
    @client = @reservation.client
    @trip = @reservation.trip

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @reservation }
    end
  end

  # GET /reservations/new
  # GET /reservations/new.xml
  def new
    @client = Client.find(params[:client_id])
    @trip = Trip.find(params[:trip_id])
    @reservation = Reservation.new :trip => @trip

    if params[:kind]
      @kind = Company.kinds.include?(params[:kind].downcase) ?
        params[:kind].downcase : nil
      @companies = Company.find_all_by_kind_and_region_id @kind, 
        Region.first.id, :order => 'companies.name'
    else
      @kind = nil
      @companies = Company.find_all_by_region_id Region.first.id,
        :order => 'companies.name'
    end

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @reservation }
    end
  end

  # GET /reservations/1/edit
  def edit
    @reservation = Reservation.find(params[:id])
    @client = Client.find(params[:client_id])
    @trip = Trip.find(params[:trip_id])

    if params[:kind]
      @kind = Company.kinds.include?(params[:kind].downcase) ?
        params[:kind].downcase : nil
      @companies = Company.find_all_by_kind_and_region_id @kind,
        @reservation.company.region.id, :order => 'companies.name'
    else
      @kind = nil
      @companies = Company.find_all_by_region_id @reservation.company.region.id,
        :order => 'companies.name'
    end

  end

  # POST /reservations
  # POST /reservations.xml
  def create
    @reservation = Reservation.new(params[:reservation])
    @client = Client.find(params[:client_id])
    @trip = Trip.find(params[:trip_id])

    respond_to do |format|
      if @reservation.save
        format.html { redirect_to([@client, @trip, @reservation], :notice => 'Reservation was successfully created.') }
        format.xml  { render :xml => @reservation, :status => :created, :location => @reservation }
      else
        @companies = []
        format.html { render :action => "new" }
        format.xml  { render :xml => @reservation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /reservations/1
  # PUT /reservations/1.xml
  def update
    @reservation = Reservation.find(params[:id])
    @client = Client.find(params[:client_id])
    @trip = Trip.find(params[:trip_id])

    respond_to do |format|
      if @reservation.update_attributes(params[:reservation])
        format.html { redirect_to([@client, @trip, @reservation], :notice => 'Reservation was successfully updated.') }
        format.xml  { head :ok }
      else
        @companies = []
        format.html { render :action => "edit" }
        format.xml  { render :xml => @reservation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /reservations/1
  # DELETE /reservations/1.xml
  def destroy
    @reservation = Reservation.find(params[:id])
    @reservation.destroy

    @client = Client.find(params[:client_id])
    @trip = Trip.find(params[:trip_id])

    respond_to do |format|
      format.html { redirect_to(client_trip_reservations_url(@client, @trip)) }
      format.xml  { head :ok }
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
end
