require 'date'

class CalendarController < ApplicationController
  before_filter :set_date

  def day
  end

  def week
  end

  def month
  end

  def year
  end

  def set_date
    if params.has_key? :date
      @date = Date.parse(params[:date])
    else
      @date = Date.today
    end
  end

end
