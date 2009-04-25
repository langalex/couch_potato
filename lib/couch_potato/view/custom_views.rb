require File.dirname(__FILE__) + '/base_view_spec'
require File.dirname(__FILE__) + '/model_view_spec'
require File.dirname(__FILE__) + '/properties_view_spec'
require File.dirname(__FILE__) + '/custom_view_spec'


module CouchPotato
  module View
    module CustomViews
      
      def self.included(base)
        base.extend ClassMethods
      end
      
      module ClassMethods
        
        def view(view_name, options)
          self.class.instance_eval do
            define_method view_name do |view_parameters = {}|
              klass = options[:type] ? options[:type].to_s.camelize : 'Model'
              CouchPotato::View.const_get("#{klass}ViewSpec").new self, view_name, options, view_parameters
            end
          end
        end
        
        def should_include_docs?(options)
          options[:include_docs] || !(options[:map] || options[:properties])
        end
        
      end
    end
  end
end
