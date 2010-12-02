# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  # make sure all links include a locale param
  def default_url_options(options={})
    { :lc => I18n.locale }
  end

  # use the locale param to actually set the proper value
  before_filter :set_locale

protected
  def set_locale
    I18n.locale = params[:lc]

    logger.debug "Using locale #{I18n.locale} based on query param lc=#{params[:lc]}\n"
  end

  class << self
    # define ipe methods with validation
    def in_place_edit_for(model, attribute)
      model = model.to_s.camelcase.constantize
      method = "set_#{model.to_s.downcase.gsub '::', '_'}_#{attribute}"
      logger.debug "Creating new method #{method}"
      define_method method do
        unless [:post, :put].include?(request.method) then
          return render :text => 'Method not allowed', :status => 405
        end

        @item = model.find params[:id]
        @item.send "#{attribute}=", params[:value]

        # saved OK
        if @item.save
          render :text => CGI::escapeHTML(@item.send(attribute).to_s)

        # save failed
        else
          render :update, :status => 999 do |js|
            # clear the bad data
            model.query_cache.clear if
              model.method_defined? :query_cache
            @item.reload

            # replace the element with the original value
            js.replace_html params[:editorId], @item.send(attribute)

            # finally, notify of errors
            js.alert(@item.errors.full_messages.join "\n")
          end
        end
      end
    end

    # collection ipe
    def in_place_collection_edit_for(model, attribute, collection=nil, &block)
      if (not block_given? and collection.nil?) or (block_given? and collection)
        raise "You must supply either a collection or a block which returns one."
      end

      # define the collection list method
      model = model.to_s.camelcase.constantize
      model_method_name = model.to_s.downcase.gsub '::', '_'
      collection_method = "get_#{model_method_name}_#{attribute}_collection"
      logger.debug "Creating collection method #{collection_method}"
      
      define_method collection_method do
        unless block.nil?
          collection ||= block.call(model, attribute)
        end

        if collection.is_a?(Hash)
          render :json => collection.to_a

        elsif collection.is_a?(Array)
          # ensure array is [[key,value], ...]
          render :json => collection.map do |e|
            if e.is_a?(Array) && e.size == 2
              e
            else
              [ e, e ].flatten.slice(0..1)
            end
          end

        else
          render :status => 999,
            :text => "Invalid collection #{collection}"
        end
      end

      save_method = "set_#{model_method_name}_#{attribute}"
      define_method save_method do
        unless [:post, :put].include?(request.method) then
          return render :text => 'Method not allowed', :status => 405
        end

        @item = model.find params[:id]
        @item.send "#{attribute}=", params[:value]

        # get collection
        unless block.nil?
          collection ||= block.call(model, attribute)
        end

        # convert to hash for lookup
        if collection.is_a?(Array)
          collection = Hash[*collection.flatten]
          collection.keys.each { |key| collection[key.to_s] = collection[key] }
        end

        # saved OK
        if @item.save
          attr_str = @item.send(attribute).to_s

          # lookup value in collection
          render :text => CGI::escapeHTML(collection[attr_str] || attr_str)

        # save failed
        else
          render :update, :status => 999 do |js|
            # clear the bad data
            model.query_cache.clear if
              model.method_defined? :query_cache
            @item.reload

            # lookup value in collection
            attr_str = @item.send(attribute).to_s

            # replace the element with the original value
            js.replace_html params[:editorId], collection[attr_str] || attr_str

            # finally, notify of errors
            js.alert(@item.errors.full_messages.join "\n")
          end
        end
      end
    end
  end
end
