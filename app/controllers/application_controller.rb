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
end
