module ActiveSupportMethods
  def camelize
    sub(/^([a-z])/) {$1.upcase}.gsub(/_([a-z])/) do
      $1.upcase
    end
  end
end
String.send :include, ActiveSupportMethods unless String.new.respond_to?(:underscore)

class String
  # inspired by http://github.com/rails/rails/blob/b600bf2cd728c90d50cc34456c944b2dfefe8c8d/activesupport/lib/active_support/inflector.rb
  def snake_case(seperator = '/')
    string = seperator == '::' ? dup : gsub(/::/, '/')
    string.gsub!(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
    string.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
    string.tr!("-", "_")
    string.downcase
  end
end
