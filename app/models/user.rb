# An authorized user. Can own one or more domains.
class User < MyMongoBase
  attributes :name => :string, :email => :string, :salt => :integer, :password => :string
end
