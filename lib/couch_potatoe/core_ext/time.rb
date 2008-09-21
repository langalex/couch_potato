class Time
  def to_json(*a)
    {
      'json_class'   => self.class.name,
      'data'         => self.strftime("%Y/%m/%d %H:%M:%S %z")
    }.to_json(*a)
  end
end

class Time
  def self.json_create(o)
    parse(*o['data'])
  end
end
