class Person
  include CouchPotato::Persistence

  property :name, type: Address
  property :ship_address
  property :information, type: Hash
end
