class Date
  def self.json_create string
    return nil if string.nil?
    Date.parse(string)
  end
end

module CouchPotatoRefinements
  refine Date do
    def to_json(*a)
      %("#{as_json}")
    end

    def as_json(*args)
      strftime("%Y/%m/%d")
    end
  end
end
