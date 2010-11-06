class RegionsController < ApplicationController
  # install callbacks for in-place editor
  in_place_edit_for :region, :name
  in_place_edit_for :region, :country

  # list countries for in-place collection editor
  def countries_list
    respond_to do |format|
      format.json { render :json => @countries }
    end
  end

  # GET /regions
  # GET /regions.xml
  def index
    @regions = Region.ordered

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @regions }
    end
  end

  # POST /regions
  # POST /regions.xml
  def create
    @region = Region.new(params[:region])

    respond_to do |format|
      if @region.save
        if request.xhr?
          format.html { render :partial => 'show', :locals => { :region => @region } }
        else
          format.html { redirect_to(@region, :notice => 'Region was successfully created.') }
          format.xml  { render :xml => @region, :status => :created, :location => @region }
        end
      else
        if request.xhr?
          format.html do
            render :update, :status => 999 do |js|
              js.alert @region.errors.full_messages.join("\n")
            end
          end
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @region.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # PUT /regions/1
  # PUT /regions/1.xml
  def update
    @region = Region.find(params[:id])

    respond_to do |format|
      if @region.update_attributes(params[:region])
        format.html { redirect_to(@region, :notice => 'Region was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @region.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /regions/1
  # DELETE /regions/1.xml
  def destroy
    @region = Region.find(params[:id])
    @region.destroy

    respond_to do |format|
      format.html { redirect_to(regions_url) }
      format.xml  { head :ok }
    end
  end
end
