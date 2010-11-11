class PeopleController < ApplicationController
  # GET /people
  # GET /people.xml
  def index
    return redirect_to :controller => :home unless params.has_key?(:trip_id)
    @people = Person.find_all_by_trip_id params[:trip_id]
    @trip = Trip.find params[:trip_id]

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @people }
    end
  end

  # GET /people/1
  # GET /people/1.xml
  def show
    @person = Person.find(params[:id])
    @trip = @person.trip

    respond_to do |format|
      format.html { render :partial => 'show' }
      format.xml  { render :xml => @person }
    end
  end

  # GET /people/1/edit
  def edit
    @person = Person.find(params[:id])
    @trip = @person.trip

    respond_to do |format|
      format.html { render :partial => @person }
    end
  end

  # PUT /people/1
  # PUT /people/1.xml
  def update
    @person = Person.find(params[:id])

    respond_to do |format|
      if @person.update_attributes(params[:person])
        format.html { render :partial => 'show' }
      else
        format.html { render :partial => @person }
      end
    end
  end

end
