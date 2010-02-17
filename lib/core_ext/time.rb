class Time
  def to_json(*a)
    %("#{to_s(:json)}")
  end
  
  def to_s_with_json(*args)
    if args[0] == :json
      getutc.strftime("%Y/%m/%d %H:%M:%S +0000")
    else
      to_s_without_json *args
    end
  end
  alias_method :to_s_without_json, :to_s
  alias_method :to_s, :to_s_with_json
  
  def self.json_create string
    return nil if string.nil?
    d = DateTime.parse(string).new_offset
    self.utc(d.year, d.month, d.day, d.hour, d.min, d.sec)
  end
end
