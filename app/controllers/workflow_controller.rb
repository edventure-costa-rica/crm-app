class WorkflowController < ApplicationController
  def client
    @client = Client.new
    @recent = Client.all(order: 'updated_at DESC').take(5)
    @search = params[:q].to_s.strip

    if @search and @search.length > 0
      @results = Client.search(@search)
    end
  end

  def trips
    @client = Client.find(params[:client_id])

    if @client.trips.count == 1
      return redirect_to workflow_reservations_url(@client.trips.first, autoredirect: true)
    elsif @client.trips.count == 0
      return redirect_to workflow_new_trip_url(@client)
    end

    trip = @client.trips.order('updated_at DESC').first
    redirect_to workflow_reservations_url(trip)
  end

  def new_trip
    @client = Client.find(params[:client_id])
  end

  def create_trip

  end

  def reservations
    render text: 'reservations'
  end

end
