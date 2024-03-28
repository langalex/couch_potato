module CouchPotato
  module GhostAttributes # :nodoc:
    def method_missing(name, *args)
      if (value = _document && _document[name.to_s])
        value
      else
        super
      end
    end
  end
end
