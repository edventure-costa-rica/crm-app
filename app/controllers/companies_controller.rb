class CompaniesController < ApplicationController
  # GET /companies
  # GET /companies.xml
  # GET /companies.js
  def index
    query = []
    binds = []
    if params.has_key? :region_id
      query << 'regions.id = ?'
      binds << params[:region_id]
    end
    if params.has_key? :q
      query << 'companies.name LIKE ?'
      binds << "#{params[:q]}%"
    end
    if params.has_key? :kind
      query << 'companies.kind = ?'
      binds << params[:kind].to_s
    end

    @companies = Company.all :order => 'companies.name',
      :include => :region,
      :conditions => [ query.join(' AND ') ].concat(binds)

    respond_to do |format|
      format.html # index.html.erb
      format.js   # index.js.erb
      format.xml  { render :xml  => @companies }
    end
  end

  # GET /companies/1
  # GET /companies/1.xml
  def show
    @company = Company.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.js   { render :text => @company.to_json }
      format.xml  { render :xml  => @company }
    end
  end

  # GET /companies/new
  # GET /companies/new.xml
  def new
    @company = Company.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @company }
    end
  end

  # GET /companies/1/edit
  def edit
    @company = Company.find(params[:id])
  end

  # POST /companies
  # POST /companies.xml
  def create
    @company = Company.new(params[:company])

    respond_to do |format|
      if @company.save
        format.html { redirect_to(@company, :notice => 'Company was successfully created.') }
        format.xml  { render :xml => @company, :status => :created, :location => @company }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @company.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /companies/1
  # PUT /companies/1.xml
  def update
    @company = Company.find(params[:id])

    respond_to do |format|
      if @company.update_attributes(params[:company])
        format.html { redirect_to(@company, :notice => 'Company was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @company.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /companies/1
  # DELETE /companies/1.xml
  def destroy
    @company = Company.find(params[:id])
    @company.destroy

    respond_to do |format|
      format.html { redirect_to(companies_url) }
      format.xml  { head :ok }
    end
  end


  def export
    name = 'companies.csv'
    header = CSV.generate_line(Company.export_header, encoding: 'UTF-8')

    csv = Company.all(order: 'kind, name').map do |company|
      CSV.generate_line(company.export, encoding: 'UTF-8')
    end

    respond_to do |format|
      format.csv { send_data header + csv.join, filename: name }
    end
  end

end
