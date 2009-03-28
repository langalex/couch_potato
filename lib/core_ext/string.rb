module ActiveSupportMethods
  def camelize
    sub(/^([a-z])/) {$1.upcase}.gsub(/_([a-z])/) do
      $1.upcase
    end
  end
  
  def underscore
    gsub(/([A-Z])/) do
      '_' + $1.downcase
    end.sub(/^_/, '')
  end
end

String.send :include, ActiveSupportMethods #unless String.new.respond_to?(:camelize)