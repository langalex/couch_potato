class Time
  def to_json(*a)
    %("#{as_json}")
  end
  
  def as_json(*args)
    getutc.strftime("%Y/%m/%d %H:%M:%S +0000")
  end
  
  def self.json_create string
    return nil if string.nil?
    d = DateTime.parse(string).new_offset
    self.utc(d.year, d.month, d.day, d.hour, d.min, d.sec)
  end
end
