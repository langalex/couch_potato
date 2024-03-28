class Date
  def to_json(*a)
    %("#{as_json}")
  end

  def as_json(*args)
    strftime("%Y/%m/%d")
  end

  def self.json_create string
    return nil if string.nil?
    Date.parse(string)
  end
end
