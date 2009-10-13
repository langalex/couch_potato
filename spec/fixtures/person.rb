class Person
  include CouchPotato::Persistence
  
  property :name, :type => Address
  property :ship_address
end