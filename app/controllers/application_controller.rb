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
  end
end
