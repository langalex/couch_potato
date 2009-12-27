module CouchPotato
  module Persistence
    class TypeCaster
      def cast(value, type)
        if type == :boolean
          cast_boolen(value)
        else
          cast_native(value, type)
        end
      end
      
      def cast_boolen(value)
        if !(value.instance_of?(FalseClass) || value.instance_of?(TrueClass))
          if value == 0 || value == '0'
            false
          elsif value.nil?
            nil
          else
            true
          end
        else
          value
        end
      end
      
      def cast_native(value, type)
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