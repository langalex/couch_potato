class Time
  def to_json(*a)
    self.strftime("%Y/%m/%d %H:%M:%S %z")
  end
end

class Time
  def self.json_create(*o)
    parse(*o)
  end
end
