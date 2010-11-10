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

  def pe_f(which)
    Person.human_attribute_name which
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
  @default_ipe_options = {
    :cancelControl  => :button,
    :okText         => I18n.t(:ok),
    :cancelText     => I18n.t(:cancel),
    :loadingText    => I18n.t(:loading),
    :savingText     => I18n.t(:saving),
    :clickToEditText=> I18n.t(:click_to_edit),
    :onFailure      => 'function(t){ }'
  }

  class << self
    attr_accessor :default_ipe_options
  end

  # in-place text editor
  def in_place_editor_field(object, method, options = {})
    element_tag = options[:tag].nil? ? "span" : options.delete(:tag)
    element_id = options[:id].nil? ?
      "#{object.class.name.downcase.gsub '::', '_'}-#{method}-#{object.id}" :
      options.delete(:id)

    callback_url = options[:url].nil? ?
      url_for({
        :action => "set_#{object.class.name.downcase}_#{method}",
        :id => object.id }) :
      options.delete(:url)

    element = content_tag element_tag, h(object.send method),
      { :id => element_id, :class => 'in_place_collection_editor_field' }.
      merge!(options.delete(:html) || {})

    ipe = javascript_tag do
      js = ''
      js << "new Ajax.InPlaceEditor("
      js << element_id.to_json
      js << ', '
      js << callback_url.to_json
      js << ', '
      js << self.class.default_ipe_options.merge(options).to_json
      js << ");"
    end

    element + ipe
  end

  # in-place collection editor
  def in_place_collection_editor_field(object, method, collection, options = {})
    element_tag = options[:tag].nil? ? "span" : options.delete(:tag)
    element_id = options[:id].nil? ?
      "#{object.class.name.downcase.gsub '::', '_'}-#{method}-#{object.id}" :
      options.delete(:id)

    callback_url = options[:url].nil? ?
      url_for({
        :action => "set_#{object.class.name.downcase}_#{method}",
        :id => object.id }) :
      options.delete(:url)

    options.merge!(self.class.default_ipe_options)

    if collection.is_a?(Hash)
      options[:collection] = collection.each_pair { |k,v| [k, v] }
    elsif collection.is_a?(Array)
      options[:collection] = collection
    elsif collection.is_a?(String)
      options[:loadCollectionURL] = collection
    end

    element = content_tag element_tag, h(object.send method),
      { :id => element_id, :class => 'in_place_collection_editor_field' }.
      merge!(options.delete(:html) || {})

    ipe = javascript_tag do
      js = ''
      js << "new Ajax.InPlaceCollectionEditor("
      js << element_id.to_json
      js << ', '
      js << callback_url.to_json
      js << ', '
      js << options.merge!(options).to_json
      js << ");"
    end

    element + ipe
  end
end