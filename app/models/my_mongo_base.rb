class MyMongoBase
  cattr_accessor :connection
  
  def initialize(record = nil, oid = nil)
    @values = record || {}
    @values[:id] = oid
  end

  def id
    @values[:id]
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
      record = {}
      @attributes.keys.each {|k| record[k] = values[k] if values[k]}
      oid = self.collection.insert(record)
      self.new(record, oid)
    end

    def collection
      coll_name = self.name.tableize
      self.database.collection(coll_name)
    end

    def find(*args)
      if args.size == 1
        if args[0] == :first
          classilize(self.collection.find_one)[0]
        elsif args[0] == :all
          classilize(self.collection.find.to_a)
        else
          classilize(self.collection.find_one(args[0]))
        end
      else
        nil
      end
    end

    def classilize(*vals)
      [*vals].flatten.collect do |record|
        oid = record.delete('_id')
        self.new(record.symbolize_keys, oid)
      end
    end
  end
end