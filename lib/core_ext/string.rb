module ActiveSupportMethods
  def camelize
    sub(/^([a-z])/) {$1.upcase}.gsub(/_([a-z])/) do
      $1.upcase
    end
  end
  
  # Source
  # http://github.com/rails/rails/blob/b600bf2cd728c90d50cc34456c944b2dfefe8c8d/activesupport/lib/active_support/inflector.rb
  def underscore
    gsub(/::/, '/').
      gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
      gsub(/([a-z\d])([A-Z])/,'\1_\2').
      tr("-", "_").
      downcase
  end
end

String.send :include, ActiveSupportMethods unless String.new.respond_to?(:underscore)