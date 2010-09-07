class RecordController < ApplicationController
  # Basic pageview recording action.
  def pageview
    logger.info "PAGEVIEW: #{params.inspect}"

    page = params[:p]
    visitor_id = params[:v]
    referrer = params[:r]
    new_visitor = 
    last_page = params[:lp]

    Pageviews.record_view(:page => params[:p], :visitor_id => params[:v],
        :referrer => params[:r], :new_visitor => (params[:nv] == "1"),
        :last_page => params[:lp])
                  
    render :nothing => true
  end
end
