require File.dirname(__FILE__) + '/base_view_spec'
require File.dirname(__FILE__) + '/model_view_spec'
require File.dirname(__FILE__) + '/properties_view_spec'
require File.dirname(__FILE__) + '/custom_view_spec'
require File.dirname(__FILE__) + '/raw_view_spec'


module CouchPotato
  module View
    module CustomViews
      
      def self.included(base)
        base.extend ClassMethods
      end
      
      module ClassMethods
        # Declare a CouchDB view, for examples on how to use see the *ViewSpec classes in CouchPotato::View
        def view(view_name, options)
          self.class.instance_eval do
            define_method view_name do |view_parameters = {}|
              view_spec_class(options[:type]).new self, view_name, options, view_parameters
            end
          end
        end
        
        def view_spec_class(type)
          if type && type.is_a?(Class)
            type
          else
            name = type.nil? ? 'Model' : type.to_s.camelize
            CouchPotato::View.const_get("#{name}ViewSpec")
          end
        end
      end
    end
  end
end
