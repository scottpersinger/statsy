class Domain < MyMongoBase
  attributes :domain => :string, :aliases => :array

  def self.lookup_by_page(page)
    
  end

  def same_domain?(url)
    
  end
end
