module CouchPotato
  module Persistence
    class TypeCaster
      def cast(value, type)
        if type && !value.instance_of?(type)
          if type == Fixnum
            value.to_s.scan(/\d/).join.to_i unless value.blank?
          else
            type.json_create value
          end
        else
          value
        end
      end
    end
  end
end