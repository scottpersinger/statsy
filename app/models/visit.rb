# A single visit to a site on a single day.
class Visit < MyMongoBase
  attributes :day => :integer, :time => :time, :source => :integer, :referral => :string

  belongs_to :landing_page, :class => Page
  belongs_to :prior_visit, :class => Visit
end
