module ActiveSupportMethods
  def camelize
    sub(/^([a-z])/) {$1.upcase}.gsub(/_([a-z])/) do
      $1.upcase
    end
  end
end
String.send :include, ActiveSupportMethods unless String.new.respond_to?(:underscore)