class MyMongoBase
  cattr_accessor :connection
  
  def initialize(record = nil)
    @values = record || {}
  end

  def id
    @values[:_id]
  end

  def self.attributes(h)
    @attributes = h.clone
    h.keys.each do |name|
      define_method(name.to_sym) {@values[name.to_sym]}
      define_method("#{name}=".to_sym) {|val| @values[name] = val}
    end
  end

  def destroy
    if self.id
      self.collection.remove(:_id => self.id)
    end
  end

  def collection
    self.class.collection
  end

  def save
    self.collection.save(serialize)
  end

  def serialize
    self.class.serialize(@values)
  end

  class << self
    def database=(name)
      @@database = self.connection.db(name)
    end
    def database; @@database; end
    
    def belongs_to(name, h = nil)
      @belongs_to ||= {}
      @belongs_to[:name] = (h && h[:class]) ? h[:class] : (name.to_s.classify.constantize)
    end

    def create(values)
      record = serialize(values)
      self.collection.insert(record)
      self.new(values.merge(:_id => record[:_id]))
    end

    def serialize(values)
      record = {}
      @attributes.each do |key, type|
        record[key] = _serialize(values[key]) if values[key]
      end
      record[:_id] = values[:_id] if values[:_id]
      record
    end

    def _serialize(value)
      case value
      when Array
        value.collect {|el| _serialize(el)}
      when Hash
        value.inject({}) { |h, (k, v)| h[k] = _serialize(v); h }
      when Numeric, TrueClass, FalseClass, NilClass, String, BSON::ObjectId
        value
      else
        value.to_mongo.merge({:klass => value.class.name})
      end
    end

    def _deserialize(value)
      case value
      when Array
        value.collect {|el| _deserialize(el)}
      when Hash
        if value['klass']
          value['klass'].constantize.from_mongo(value)
        else
          value.inject({}) { |h, (k, v)| h[k] = _deserialize(v); h }
        end
      else
        value
      end
    end

    def collection(name = nil)
      coll_name = name || self.name.tableize
      self.database.collection(coll_name)
    end

    def find(*args)
      if args.size == 1 && !args[0].is_a?(Hash)
        if args[0] == :first
          classilize(self.collection.find_one)[0]
        elsif args[0] == :all
          classilize(self.collection.find.to_a)
        else
          classilize(self.collection.find_one(args[0]))[0]
        end
      else
        cursor = self.collection.find(*args)
        if cursor.count > 0
          classilize(cursor.to_a)
        else
          []
        end
      end
    end

    def find_one(*args)
      self.collection.find_one(*args)
    end
    
    def destroy_all
      self.collection.remove
    end

    def count
      self.collection.find.count
    end
    
    def classilize(*vals)
      [*vals].flatten.collect do |record|
        values = record.inject({}) { |h, (k, v)| h[k.to_sym] = _deserialize(v); h }
        self.new(values)
      end
    end
  end
end