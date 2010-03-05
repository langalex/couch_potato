module CouchPotato
  module Persistence
    class TypeCaster #:nodoc:
      def cast(value, type)
        if type == :boolean
          cast_boolen(value)
        else
          cast_native(value, type)
        end
      end
      
      private
      
      def cast_boolen(value)
        if [FalseClass, TrueClass].include?(value.class) || value.nil?
          value
        elsif [0, '0'].include?(value)
          false
        else
          true
        end
      end
      
      def cast_native(value, type)
        if type && !value.instance_of?(type)
          if type == Fixnum
            value.to_s.scan(/\d/).join.to_i unless value.blank?
          elsif type == Float
            value.to_s.scan(/\d+\.?\d*/).join.to_f unless value.blank?
          else
            type.json_create value unless value.blank?
          end
        else
          value
        end
      end
      
    end
  end
end