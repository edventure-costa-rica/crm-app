class ClientsController < ApplicationController
  # GET /clients
  # GET /clients.xml
  def index
    @clients = Client.all :order => :family_name

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @clients }
    end
  end

  # GET /clients/1
  # GET /clients/1.xml
  def show
    @client = Client.find(params[:id])
    @trip = Trip.first :order => 'arrival', :conditions => [ 
      'client_id = ? AND departure >= ?', params[:id], Date.today
    ]

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @client }
    end
  end

  # GET /clients/new
  # GET /clients/new.xml
  def new
    @client = Client.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @client }
    end
  end

  # GET /clients/1/edit
  def edit
    @client = Client.find(params[:id])
  end

  # POST /clients
  # POST /clients.xml
  def create
    @client = Client.new(params[:client])

    respond_to do |format|
      if @client.save
        format.html { redirect_to(@client, :notice => 'Client was successfully created.') }
        format.xml  { render :xml => @client, :status => :created, :location => @client }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @client.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /clients/1
  # PUT /clients/1.xml
  def update
    @client = Client.find(params[:id])

    respond_to do |format|
      if @client.update_attributes(params[:client])
        format.html { redirect_to(@client, :notice => 'Client was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @client.errors, :status => :unprocessable_entity }
      end
    end
  end

  def remove
    @client = Client.find(params[:id])
    
    respond_to do |format|
      format.html { render :action => "remove" }
    end
  end

  # DELETE /clients/1
  # DELETE /clients/1.xml
  def destroy
    @client = Client.find(params[:id])
    @client.destroy
    
    respond_to do |format|
      format.html { redirect_to(clients_url) }
      format.xml  { head :ok }
    end
  end

  def search
    query = params[:q].to_s

    results = Client.search(query, order: 'updated_at DESC').take(10).map do |c|
       { url: client_url(c),
         name: c.to_s,
         email: c.email.to_s,
         phone: c.phone
       }
    end

    render json: results
  end

  def export
    name = 'clients.csv'

    header = CSV.generate_line(Client.export_header, encoding: 'UTF-8')

    csv = Client.all.map do |client|
      CSV.generate_line(client.export, encoding: 'UTF-8')
    end

    respond_to do |format|
      format.csv { send_data header + csv.join, filename: name }
    end
  end

end
