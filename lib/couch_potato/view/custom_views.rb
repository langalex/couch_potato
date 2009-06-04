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
        def views
          @views ||= {}
        end

        def execute_view(view_name, view_parameters)
          view_spec_class(views[view_name][:type]).new(self, view_name, views[view_name], view_parameters)
        end

        def view(view_name, options)
          view_name = view_name.to_s
          views[view_name] = options
          method_str = "def #{view_name}(view_parameters = {}); execute_view(\"#{view_name}\", view_parameters); end"
          self.instance_eval(method_str)
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
