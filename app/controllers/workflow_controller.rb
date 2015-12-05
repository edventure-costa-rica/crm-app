class WorkflowController < ApplicationController
  def client
    @search = params[:q].to_s.strip
    if @search and @search.length > 0
      @results = Client.search(@search)
    end
  end

end
