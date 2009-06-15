class Person
  include CouchPotato::Persistence
  
  property :name
  property :ship_address, :type => Address
end