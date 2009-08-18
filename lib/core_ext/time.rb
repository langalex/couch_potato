class Time
  def to_json(*a)
    %("#{strftime("%Y/%m/%d %H:%M:%S %z")}")
  end
  
  def self.json_create string
    return nil if string.nil?
    d = DateTime.parse(string).new_offset
    self.utc(d.year, d.month, d.day, d.hour, d.min, d.sec)
  end
end
