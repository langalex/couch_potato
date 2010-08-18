module CouchPotato
  module Validation
    module WithValidatable
      def self.included(base)
        begin
          require 'validatable'
        rescue LoadError
          puts "Please install the gem validatable using 'gem install validatable'"
          raise
        end
        base.send :include, ::Validatable
        base.class_eval do
          # Override the validate method to first run before_validation callback
          def valid?
            errors.clear
            run_callbacks :validation do
              before_validation_errors = errors.errors.dup
              super
              before_validation_errors.each do |k, v|
                v.each {|message| errors.add(k, message)}
              end
            end
            errors.empty?
          end
        end
      end
    end
  end
end

# add [] method to Validatable's implementation of the Errors class
module Validatable
  class Errors
    def [](attribute)
      [on(attribute)].flatten.compact
    end
  end
end
