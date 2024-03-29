# frozen_string_literal: true

require 'bigdecimal/util'
module CouchPotato
  module Persistence
    class TypeCaster #:nodoc:
      NUMBER_REGEX = /-?\d*\.?\d*/.freeze

      def cast(value, type)
        if type == :boolean
          cast_boolean(value)
        elsif type.instance_of?(Array)
          nested_type = type.first
          value&.map { |val| cast_native(val, nested_type) }
        else
          cast_native(value, type)
        end
      end

      def cast_back(value)
        if value.is_a?(Time)
          value.utc
        else
          value
        end
      end

      private

      def cast_boolean(value)
        if [FalseClass, TrueClass].include?(value.class) || value.nil?
          value
        elsif [0, '0', 'false'].include?(value)
          false
        else
          true
        end
      end

      def cast_native(value, type)
        return if value.nil?
        if type && !value.is_a?(type)

          if %w[Integer Bignum Fixnum].include?(type.to_s)
            value.to_s.scan(NUMBER_REGEX).join.to_d.round unless value.blank?
          elsif type == Float
            value.to_s.scan(NUMBER_REGEX).join.to_f unless value.blank?
          elsif type == BigDecimal
            value.to_d unless value.blank?
          elsif type == Hash
            value.to_hash unless value.blank?
          elsif type == Time
            Time.parse value unless value.blank?
          elsif type == Date
            Date.parse value unless value.blank?
          elsif type.ancestors.include?(CouchPotato::Persistence)
            type.new value unless value.blank?
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
