require 'time'

## A single visit to a site on a single day.
class Visit < MyMongoBase
  attributes :day => :integer, :time => :time, :source => :integer, :referral => :string

  def self.record_visit(domain, values)
    update_visitors(domain, values)
  end

  # Here we keep track of the count of visitors (i.e. "people") to a domain
  # for various time periods:
  #  daily: the number of people who visited on day X
  #  weekly: the number of people who visited between day X and 6 days prior
  #  monthly: the number of people who visited in the current calendary month
  #
  # We track visitors over intervals by keeping a "last_visit" timestamp cooke
  # on the client. If the timestamp is within the period of the interval then
  # we don't count an additional visitor.
  def self.update_visitors(domain, values)
    [:day, :week, :month].each do |interval_key|
      today = domain.today
      interval_val = nil
      start_time = case interval_key
      when :day
        interval_val = today.mongo_key
        Time.parse(today.to_s) # FIXME: Handle timezone
      when :week
        interval_val = today.mongo_key
        Time.parse((today - 6).to_s)
      when :month
        interval_val = today.mongo_key / 100
        Time.parse(today.to_s.gsub(/\d\d$/,'01'))
      end

      last_client_visit = convert_last_visit_time(values[:last_visit])
      if last_client_visit.nil? || last_client_visit < start_time
        domain.visitors_collection.update({interval_key => interval_val, :domain => domain.id},
          {:$inc => {:count => 1}}, :upsert => true, :safe => true)
      end
    end
  end

  def self.convert_last_visit_time(last_visit_cookie)
    last_visit_cookie ? Time.at((last_visit_cookie.to_s[0..-4]).to_i) : nil
  end
end
