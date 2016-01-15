class TripsController < ApplicationController
  INDEX_PAGE_INTERVAL = 90

  # GET /trips
  # GET /trips.xml
  def index
    if params[:client_id].nil?
      @trips = Trip.all :order => 'arrival DESC'
    else
      @trips = Trip.find :all, :order => 'arrival DESC',
        :conditions => [ 'client_id = ?', params[:client_id] ]
      @client = Client.find(params[:client_id])
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @trips }
    end
  end

  # GET /trips/upcoming
  def upcoming
    @trips = Trip.all :order => 'arrival ASC',
      :conditions => ['departure >= ?', Date.today]

    @upcoming = true

    respond_to do |format|
      format.html { render :action => 'index' }
      format.xml  { render :xml => @trips }
    end
  end

  # GET /clients/:client_id/trips/new
  def new
    @trip = Trip.new
    @client = Client.find(params[:client_id])

    @trip.client = @client

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @trip }
    end
  end

  # POST /clients/:client_id/trips
  def create
    @client = Client.find(params[:client_id])
    @trip = @client.trips.build(trip_params)

    respond_to do |format|
      if @trip.save
        format.html { redirect_to(pending_trip_reservations_url(@trip),
                                  :notice => 'Trip was successfully created.') }
        format.xml  { render :xml => @trip, :status => :created, :location => @trip }
      else
        flash[:notice] = @trip.errors.full_messages.join(', ')

        format.html { render :action => "new" }
        format.xml  { render :xml => @trip.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /trips/1
  # PUT /trips/1.xml
  def update
    @trip = Trip.find(params[:id])
    @client = @trip.client

    url =
      if params[:next] == 'confirmed'
        confirmed_trip_reservations_url(@trip)
      else
        pending_trip_reservations_url(@trip)
      end

    respond_to do |format|
      if @trip.update_attributes(trip_params)
        format.html { redirect_to(url, :notice => 'Trip was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @trip.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /trips/1
  # DELETE /trips/1.xml
  def destroy
    @trip = Trip.find(params[:id])
    @client = @trip.client

    @trip.destroy

    respond_to do |format|
      format.html { redirect_to(@client) }
      format.xml  { head :ok }
    end
  end


  private

  def trip_params
    params[:trip].tap do |input|
      arrival = Chronic.parse input.delete(:arrival)
      departure = Chronic.parse input.delete(:departure)

      input[:arrival] = arrival.to_date     if arrival
      input[:departure] = departure.to_date if departure

      pax = input.delete(:pax)

      if pax
        total, children = pax.to_s.split('/', 2).map(&:to_i)
        input[:total_people] = total
        input[:num_children] = children
      end
    end
  end

end
