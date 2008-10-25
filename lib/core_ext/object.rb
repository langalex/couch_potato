Object.class_eval do
  def try(method, *args)
    self.send method, *args if self.respond_to?(method)
  end
end