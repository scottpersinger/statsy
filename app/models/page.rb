class Page
  attr_accessor :pattern, :id, :domain

  def initialize(pattern, domain = nil)
    self.domain = domain
    self.pattern = pattern.respond_to?(:path) ? pattern.path : pattern
    if self.pattern == ""
      self.pattern = "/"
    else
      self.pattern = self.pattern.sub(/(.)\/$/,"\\1")
    end
    self.id = Time.now.to_i.to_s + "-" + rand(9999).to_s
  end

  def matches?(uri)
    uri = Addressable::URI.parse(uri)
    path = uri.path.blank? ? "/" : uri.path
    pat = Regexp.escape(self.pattern).gsub('/','\/').gsub(/\*/,'.*?')
    r = Regexp.new("^#{pat}$")
    r.match(path.sub(/(.)\/$/,"\\1"))
  end

  def to_mongo
    {:id => self.id, :pattern => self.pattern}
  end

  def self.from_mongo(values)
    p = Page.new(values['pattern'])
    p.id = values['id']
    p
  end
end
