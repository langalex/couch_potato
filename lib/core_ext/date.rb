class Date
  def to_json(*a)
    %("#{strftime("%Y/%m/%d")}")
  end
  
  def self.json_create string
    return nil if string.nil?
    Date.parse(string)
  end
end
