module CouchPotato
  module GhostAttributes # :nodoc:
    def method_missing(name, *args)
      if (value = _document && _document[name.to_s])
        value
      else
        super
      end
    end

    def respond_to_missing?(name)
      _document && _document[name.to_s]
    end
  end
end
