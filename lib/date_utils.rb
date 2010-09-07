class Date
  def mongo_key
    self.strftime("%Y%m%d").to_i
  end
end