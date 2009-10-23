## Changes

### 0.2.13

* support adding errors in before_validation callbacks (mattmatt)
* support for inheritance (mattmatt)
* support for save without validations (mattmatt)
* improved (de)serialization now supports deserializing nested objects (railsbros, specs by hagenburger)

### 0.2.10
* fixed bug with hardcoded timezone

### 0.2.9

* allow to overwrite attribute accessor of properties and use super to call the original accessors
* allow read access to attributes that are present in the Couchdb document but not defined as properties
* support default values for properties via the :default parameter
* support attachments via the _attachments property
* support for namespaces models
* removed belongs_to macro for now
* removed CouchPotato::Config.database_server, just set CouchPotato::Config.database_name to the full url if you are not using localhost:5984
* Ruby 1.9 was broken and is now working again