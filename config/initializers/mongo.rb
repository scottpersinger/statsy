MyMongoBase.connection = Mongo::Connection.new('localhost', 27017)
MyMongoBase.database = "statys=#{Rails.env}"
