class HomeController < ApplicationController
  def index
    @recent = Trip.all(order: 'updated_at DESC').take(10)
  end

  def redirect
    redirect_to action: :index
  end

end
