# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def hnl(text)
    h(text).gsub(/\r?\n/, "<br/>\n")
  end

  def re_f(which)
    Reservation.human_attribute_name which
  end

  def cl_f(which)
    Client.human_attribute_name which
  end

  def co_f(which)
    Company.human_attribute_name which
  end

  def tr_f(which)
    Trip.human_attribute_name which
  end

  def title
    model, obj = if controller.class == TripsController
      [Trip, @trip]
    elsif controller.class == ReservationsController
      [Reservation, @reservation]
    elsif controller.class == ClientsController
      [Reservation, @client]
    elsif controller.class == CompaniesController
      [Company, @company]
    end

    t = ''
    if model then
      t << model.human_name(:count => 0)
      t << ": "
      t << I18n.translate(controller.action_name)
      t << " #{obj}" if obj
      t << " - "
    end

    t << I18n.translate(:app_title)
  end
end

class ActiveRecord::Base
  # treat empty strings as nil
  before_validation :convert_blanks_to_nil

protected
  def convert_blanks_to_nil
    @attributes.each do |key, value|
      self[key] = nil if value.blank?
    end
  end
end