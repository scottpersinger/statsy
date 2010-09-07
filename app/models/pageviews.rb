class Pageviews < MyMongoBase
  # Core function for recording pageviews and visits.
  def self.record_view(values)
    raise ArgumentError.new("missing :page") unless values[:page]
    raise ArgumentError.new("missing :visitor_id") unless values[:visitor_id]
    raise ArgumentError.new("missing :referrer") unless values[:referrer]

    domain = Domain.lookup_by_page(values[:page])

    if domain.same_domain?(values[:referrer])
      # just record the pageview
      record_page_view(domain, values)
    else
      # LANDING
      if !values[:last_page].blank?
        # Still the same visit, cause last_page cookie was passed
        values[:referrer] = values[:last_page]
        record_page_view(domain, values)
      else
        # Yay! A new visit.
        Visit.record_visit(domain, values)
      end
    end
  end
end
