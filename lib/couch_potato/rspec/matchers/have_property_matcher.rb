module CouchPotato
  module RSpec
    class HavePropertyMatcher

      def initialize(name)
        @name    = name
        @options = {}
      end

      def of_type(property_type)
        @options[:type] = property_type
        self
      end

      def with_options(opts={})
        %w(default).each do |opt|
          opt = opt.to_sym
          @options[opt] = opts[opt] if opts.key?(opt)
        end
        self
      end

      def matches?(subject)
        @subject = subject
        property_exists? && correct_property_type? && correct_default?
      end

      def failure_message_for_should
        "Expected #{expectation}" + help_text
      end

      def failure_message_for_should_not
        "Did not expect #{expectation}" + help_text
      end

      protected

        def property_exists?
          !matched_property.nil?
        end

        def correct_property_type?
          return true unless @options.key?(:type)

          if matched_property.type.to_s == @options[:type].to_s
            true
          else
            @help = "#{@subject} has a property named `#{@name}' " +
              "of type #{matched_property.type}, " +
              "not #{@options[:type]}"
            false
          end
        end

        def correct_default?
          return true unless @options.key?(:default)
          val = @subject.new.send(matched_property.name)

          if val == @options[:default]
            true
          else
            @help = "#{@subject} has a property named `#{@name}' " +
              "with default #{val}, " +
              "not #{@options[:default]}"
            false
          end
        end

        def matched_property
          @matched_property ||= begin
            @subject.properties.detect { |p| p.name == @name }
          end
        end

        def expectation
          str = "#{@subject} to have a property named `#{@name}'"
          str << " of type #{@options[:type]}" if @options.key?(:type)
          str << " of default #{@options[:default]}" if @options.key?(:default)
          str
        end

        def help_text
          @help ? " (#{@help})" : ""
        end
    end
  end
end
