require 'addressable/uri'

class Domain < MyMongoBase
  attributes :domain => :string, :aliases => :array, :pages => :array

  def self.lookup_by_page(uri)
    uri = Addressable::URI.parse(uri)
    host = normalize(uri.host)
    find(:domain => host)[0] || Domain.create(:domain => host)
  end

  def same_domain?(uri)
    return false if uri.nil?
    uri = Addressable::URI.parse(uri)
    host = self.class.normalize(uri.host)
    host == self.domain
  end

  def lookup_page(uri)
    return nil unless uri
    self.pages ||= []
    uri = Addressable::URI.parse(uri)
    if uri.host && self.class.normalize(uri.host) != self.domain
      # page does not belong to this domain
      nil
    else
      defined_page = self.pages.find {|defined_page| defined_page.matches?(uri)} || add_page(uri)
    end
  end

  def add_page(uri)
    new_page = Page.new(uri, self)
    self.pages ||= []
    self.pages << new_page
    self.save
    new_page
  end

  def pageviews_collection_name
    "pageviews_" + self.domain.gsub(/\./,'_')
  end

  def visitors_collection
    self.class.collection("visitors")
  end
  
  # FIXME: correct to return propery day by timezone
  def today
    Date.today
  end

  private
    def self.normalize(host)
      host.gsub(/^www\./,'')
    end
end
