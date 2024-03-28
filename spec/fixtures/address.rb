class Address
  include CouchPotato::Persistence

  property :street
  property :city
  property :state
  property :zip
  property :country
  property :verified, type: :boolean
end
