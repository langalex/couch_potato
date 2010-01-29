if CouchPotato::Config.validation_framework == :validatable
  # add [] method to Validatable's implementation of the Errors class
  module Validatable
    class Errors
      def [](attribute)
        [on(attribute)].flatten.compact
      end
    end
  end
end
