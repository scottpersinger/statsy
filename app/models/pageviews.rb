class Pageviews
  # attributes :day => :integer, :page_id => :string, :views => :integer,
  #  :visits => :integer, :exits => :integer, :time_on_page => :integer

  def initialize(domain = nil)
    @domain = domain
  end

  def collection
    raise ArgumentError, "no domain set" unless @domain
    @domain.class.database.collection(@domain.pageviews_collection_name)
  end

  # Core function for recording pageviews and visits.
  # Arguments are:
  #  :page => URI of requested page
  #  :visitor_id => id of visitor
  #  :referrer => HTTP_REFERER header value
  #  :last_page => optional value of last_page cookie
  #  :last_visit => timestamp of the last visit (recorded by cookie)
  def record_view(values)
    raise ArgumentError.new("missing :page") unless values[:page]
    raise ArgumentError.new("missing :visitor_id") unless values[:visitor_id]
    raise ArgumentError.new("missing :referrer") unless values[:referrer]

    @domain = Domain.lookup_by_page(values[:page])

    if !@domain.same_domain?(values[:referrer])
      # LANDING
      if !values[:last_page].blank?
        # Still the same visit, cause last_page cookie was passed
        values[:referrer] = values[:last_page]
        record_page_view(values)
      else
        record_page_view(values)

        # Yay! A new visit.
        Visit.record_visit(@domain, values)
      end
    else
      record_page_view(values)
      update_referrer(values[:referrer])
    end

  end

  def record_page_view(values)
    page = @domain.lookup_page(values[:page])
    refer_page = @domain.lookup_page(values[:referrer])

    # Run a Mongo update, incrementing the views number of the indicated page. Crafty
    # part is that the pageviews record will be created if it doesn't yet exist.

    refer_update = refer_page ? {"ref.#{refer_page.id}" => 1} : {}
    self.collection.update({:day => Date.today.mongo_key, :page => page.id},
      {:$set => {:day => Date.today.mongo_key, :page => page.id, :path => page.pattern}, 
        :$inc => {:views => 1, :exits => 1}.merge(refer_update)},
      :upsert => true, :safe => true)

  end

  # Update referrering page based on an internal page view.
  def update_referrer(referrer)
    return unless referrer
    page = @domain.lookup_page(referrer)

    if page
      # TODO: calculate time_on_page for referring page
      self.collection.update({:day => Date.today.mongo_key, :page => page.id},
        {:$inc => {:exits => -1}},
        :upsert => true, :safe => true)
    end
    
  end

  ############# CALCULATIONS #########################

  def count(page = nil, date = Date.today)
    if page
      rec = self.collection.find_one(:day => date.mongo_key, :page => @domain.lookup_page(page).id)
      rec ? rec['views'] : 0
    else
      total = 0
      self.collection.find(:day => date.mongo_key).each {|rec| total += (rec['views'] || 0)}
      total
    end
  end

  # Returns a Hash {Page => count} values with all the pages that referred to the
  # indicated one and their counts.
  def referrals
    
  end
end
