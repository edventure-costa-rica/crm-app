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

class ActionView::Base
  # in-place collection editor
  def in_place_collection_editor_field(object, method, collection, options = {})
    element_tag = options[:tag].nil? ? "span" : options.delete(:tag)
    element_id = options[:id].nil? ?
      "#{object.class.name.downcase}-#{method}-#{object.id}" :
      options.delete(:id)

    callback_url = options[:url].nil? ?
      url_for({
        :action => "set_#{object.class.name.downcase}_#{method}",
        :id => object.id }) :
      options.delete(:url)

    collection_options = {}
    if collection.is_a?(Hash)
      collection_options[:collection] = collection.each_pair { |k,v| [k, v] }
    elsif collection.is_a?(Array)
      collection_options[:collection] = collection
    elsif collection.is_a?(String)
      collection_options[:loadCollectionURL] = collection
    end

    element = content_tag element_tag, h(object.send method),
      { :id => element_id, :class => 'in_place_collection_editor_field' }.
      merge!(options.delete(:element_options) || {})

    ipe = javascript_tag do
      js = ''
      js << "new Ajax.InPlaceCollectionEditor("
      js << element_id.to_json
      js << ', '
      js << callback_url.to_json
      js << ', '
      js << collection_options.merge!(options).to_json
      js << ");"
    end

    element + ipe
  end
end
