class TripsController < ApplicationController
  # GET /trips
  # GET /trips.xml
  def index
    if params[:client_id].nil? then
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

  # GET /trips/1
  # GET /trips/1.xml
  def show
    @trip = Trip.find(params[:id])
    @client = Client.find(params[:client_id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @trip }
    end
  end

  # GET /trips/new
  # GET /trips/new.xml
  def new
    @trip = Trip.new
    @client = Client.find(params[:client_id])

    @trip.client = @client

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @trip }
    end
  end

  # GET /trips/1/edit
  def edit
    @trip = Trip.find(params[:id])
    @client = Client.find(params[:client_id])
  end

  # POST /trips
  # POST /trips.xml
  def create
    @trip = Trip.new(params[:trip])
    @client = Client.find(params[:client_id])

    @trip.client = @client

    respond_to do |format|
      if @trip.save
        format.html { redirect_to([@client, @trip], :notice => 'Trip was successfully created.') }
        format.xml  { render :xml => @trip, :status => :created, :location => @trip }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @trip.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /trips/1
  # PUT /trips/1.xml
  def update
    @trip = Trip.find(params[:id])
    @client = Client.find(params[:client_id])

    respond_to do |format|
      if @trip.update_attributes(params[:trip])
        format.html { redirect_to([@client, @trip], :notice => 'Trip was successfully updated.') }
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
    @trip.destroy

    @client = Client.find(params[:client_id])
    respond_to do |format|
      format.html { redirect_to(client_trips_url @client) }
      format.xml  { head :ok }
    end
  end
end
