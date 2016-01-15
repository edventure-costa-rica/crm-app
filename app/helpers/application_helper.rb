# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def item_link_with_active(*args, &blk)
    if block_given?
      contents = capture(&blk)
      link_options = args.shift || {}
      options = args.shift || {}
    else
      contents = args.shift || ''
      link_options = args.shift || {}
      options = args.shift || {}
    end

    tag = options.fetch(:item_tag, :li)
    active = options.fetch(:active_class, :active)
    item_options = current_page?(link_options) ? {class: active} : {}

    if options.has_key? :class
      item_options[:class] = [
          item_options.delete(:class),
          options.delete(:class)
      ].compact.join(' ')
    end

    item_options = options.merge(item_options)

    link_contents = link_to(contents, link_options)
    tag_contents = content_tag(tag, link_contents, item_options)

    if block_given?
      concat(tag_contents)
    else
      tag_contents
    end
  end

  def usd(value)
    precision = value.to_i == value.to_f ? 0 : 2
    number_to_currency(value, precision: precision)
  end

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
    elsif controller.class == RegionsController
      [Region, nil]
    elsif controller.class == PeopleController
      [Person, @trip]
    elsif controller.class == CalendarController
      [Reservation, l(@date.to_date, format: :calendar)]
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
  @default_ipe_options = nil

  # get the current url
  def current_url(params = {})
    url_for :overwrite_params => params
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

    element = content_tag element_tag, h(object.send(method).to_s),
      { :id => element_id, :class => 'in_place_collection_editor_field' }.
      merge!(options.delete(:html) || {})

    # external control is an edit icon by default
    if options[:externalControl] === true or not options.has_key? :externalControl
      external = image_tag 'edit.gif', :id => "#{element_id}_external",
        :style => 'vertical-align: middle'
      options[:externalControl] = "#{element_id}_external"
    elsif options[:externalControl] === false
      external = ''
    end

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

    element + external + ipe
  end

  # in-place collection editor
  def in_place_collection_editor_field(object, method, collection = nil, options = {})
    element_tag = options[:tag].nil? ? "span" : options.delete(:tag)
    element_id = options[:id].nil? ?
      "#{object.class.name.downcase.gsub '::', '_'}-#{method}-#{object.id}" :
      options.delete(:id)

    field_controller = options.delete(:controller) || controller

    callback_url = options[:url].nil? ?
      url_for({
        :action => "set_#{object.class.name.downcase}_#{method}",
        :controller => field_controller.controller_name,
        :id => object.id }) :
      options.delete(:url)

    # let the response do the work, don't rely on Ajax.Updater
    options[:htmlResponse] = false
    options[:ajaxOptions] = { :method => :post }

    options = self.class.default_ipe_options.merge(options)

    if collection.is_a?(Hash)
      options[:collection] = collection.each_pair { |k,v| [k, v] }
    elsif collection.is_a?(Array)
      options[:collection] = collection
    elsif collection.is_a?(String)
      options[:loadCollectionURL] = collection
    elsif collection.nil?
      # specifically defined inline as false
      if options.has_key?(:inline) and not options.delete(:inline)
        options[:loadCollectionURL] = url_for({
          :action => "get_#{object.class.name.downcase}_#{method}_collection",
          :controller => field_controller.controller_name,
          :id => object.id
        })

      # normally, just put the collection inline (its faster)
      else
        collection_method = "_#{object.class.name.downcase}_#{method}_collection_assoc"
        options[:collection] = field_controller.send collection_method
      end
    end

    # set 'value' key to the raw attribute value
    options[:value] = object.send(method) unless
      options.has_key? :value

    # get the display value via a collection lookup
    unless options.has_key? :display
      # XXX get the collection from the controller.
      collection_method = "_#{object.class.name.downcase}_#{method}_collection_assoc"
      collection_hash = Hash[field_controller.send collection_method]

      options[:display] = collection_hash[options[:value]]
    end

    element = content_tag element_tag, h(options.delete(:display)),
      { :id => element_id, :class => 'in_place_collection_editor_field' }.
      merge!(options.delete(:html) || {})

    # external control is an edit icon by default
    if options[:externalControl] === true or not options.has_key? :externalControl
      external = image_tag 'edit.gif', :id => "#{element_id}_external",
        :style => 'vertical-align: top'
      options[:externalControl] = "#{element_id}_external"
    elsif options[:externalControl] === false
      external = ''
    end

    ipe = javascript_tag do
      js = "$(#{element_id.to_json}).editor = "
      js << "new Ajax.InPlaceCollectionEditor("
      js << element_id.to_json
      js << ', '
      js << callback_url.to_json
      js << ', '
      js << options.merge!(options).to_json
      js << ");"
    end

    element + external  + ipe
  end

private
  # generate at runtime to use the proper locale
  def self.default_ipe_options
    @default_ipe_options ||= {
      :cancelControl  => :button,
      :okText         => I18n.t(:ok),
      :cancelText     => I18n.t(:cancel),
      :loadingText    => I18n.t(:loading),
      :savingText     => I18n.t(:saving),
      :clickToEditText=> I18n.t(:click_to_edit),
      :highlightColor => '',
      :highlightEndColor => '',
      :onFailure      => 'function(t){ }'
    }
  end
end


module ActionView::Helpers
  module AssetTagHelper
    def babel_src_tag(*sources)
      options =
        if sources.last.is_a? Hash
          sources.pop
        else
          Hash.new
        end

      sources.map do |source|
        content_tag("script", "", {
          "type" => 'text/babel',
          "src" => path_to_javascript(source)
        }.merge(options.stringify_keys))
      end.join
    end
  end

  class InstanceTag
    def to_select_year_tag(options = {}, html_options = {})
      datetime_selector(options, html_options).select_year.html_safe
    end

    def to_select_month_tag(options = {}, html_options = {})
      datetime_selector(options, html_options).select_month.html_safe
    end

    def to_select_day_tag(options = {}, html_options = {})
      datetime_selector(options, html_options).select_day.html_safe
    end
  end

  module DateHelper
    def select_year(object_name, method, options = {}, html_options = {})
      InstanceTag.new(object_name, method, self, options.delete(:object)).to_select_year_tag(options, html_options)
    end

    def select_month(object_name, method, options = {}, html_options = {})
      InstanceTag.new(object_name, method, self, options.delete(:object)).to_select_month_tag(options, html_options)
    end

    def select_day(object_name, method, options = {}, html_options = {})
      InstanceTag.new(object_name, method, self, options.delete(:object)).to_select_day_tag(options, html_options)
    end
  end

  module FormHelper
    def input_field(object_name, method, options = {})
      type = options.delete(:type) || "text"
      InstanceTag.new(object_name, method, self, options.delete(:object)).to_input_field_tag(type, options)
    end

    def number_field(object_name, method, options = {})
      input_field(object_name, method, options.merge(type: 'number'))
    end

    def reset_button(value = "Reset", options = {})
      if value.is_a? Hash
        options = value
        value = "Reset"
      end

      tag :input, { value: value, type: :reset }.merge(options)
    end
  end

  class FormBuilder
    def select_year(method, options = {}, html_options = {})
      @template.select_year(@object_name, method, objectify_options(options), html_options)
    end

    def select_month(method, options = {}, html_options = {})
      @template.select_month(@object_name, method, objectify_options(options), html_options)
    end

    def select_day(method, options = {}, html_options = {})
      @template.select_day(@object_name, method, objectify_options(options), html_options)
    end

    def pax_field(method, options = {})
      @template.text_field(@object_name, method, objectify_options(
          options.merge(placeholder: 'pax/children/disabled')))
    end

    def number_field(method, options = {})
      @template.number_field(@object_name, method, objectify_options(options))
    end

    def input_field(method, options = {})
      @template.input_field(@object_name, method, objectify_options(options))
    end
  end
end


class String
  def escape_like(quote_char = '\\')
    q = Regexp.quote(quote_char)
    self.gsub(/[#{q}%_]/) { |c| q + c }
  end

  def clean_email
    self.tr('[]', '<>').sub(/^<(.+)>$/, '\\1')
  end
end
