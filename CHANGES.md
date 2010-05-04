## Changes

### 0.2.31
* Removed requirement for validatable gem. Allows for using more uptodate versions of the library, or doesn't install it when you're using ActiveModel. (mattmatt)
* fixed callbacks of super classes were not run (langalex)

### 0.2.30
* pass in multiple keys when querying a view (langalex)

### 0.2.29
* nicer inspect() for models (mattmatt)
* fixed (re)reduce for property views wasn't working (langalex)

### 0.2.28
* fixed reloading nested classes (langalex)
* fixed constant missing error when loading models with uninitialized classes via views (langalex)
* added rspec helpers for stubbing out views (langalex)
* fixed design document names for nested model classes (svenfuchs)

### 0.2.27
* workaround for Rails apps using bundler: database name was not initialized from couchdb.yml (langalex)

### 0.2.26
* added to_s(:json) to Date and Time to be able to get properly formatted dates/times for searching with dates/times (langalex)
* all times are now stored as UTC (langalex)
* added support for Float attributes (arbovm)


### 0.2.25
* automatic view updates: when you change the definition of a view couch potato will now update the design document in the database (langalex)
* support for properties of type Date, better support for Time (langalex)
* support for default reduce count methods in custom views (jweiss)

### 0.2.24
* persistent instances can now be marked as dirty with #is_dirty (langalex)

### 0.2.23
* Couch Potato models now conform to the ActiveModel interface when ActiveModel is installed, see http://yehudakatz.com/2010/01/10/activemodel-make-any-ruby-object-feel-like-activerecord/ (langalex)
* fixed error with dirty tracking and BigDecimals (thilo)
* added the ability to use ActiveModel validations instead of validatable (martinrehfeld)

### 0.2.22
* fixed properties with default values returned default when a blank value like '' or [] was set (langalex)

### 0.2.21
* automatically set a database instance on results of CouchPotato::Database#view (langalex)
* improved auto loading of unloaded constants - can now load constants that have never been loaded before (langalex)
* raise exception on invalid parameters passed to a couchdb view query (langalex)
* when querying a view: pass in ranges as key instead of startkey/endkey, pass in plain value instead of hash with key (langalex) 

### 0.2.20
* support for :boolean properties (jweiss)
* return the total_rows when querying a view (langalex)

### 0.2.19
* added conditions to views (langalex)

### 0.2.18
* set Fixnum property to nil when given a blank string (langalex)

### 0.2.17
* fixed nil attributes were omitted in json (jweiss, mattmatt)
* support for properties of type Fixnum (langalex)

### 0.2.16
* fixed problem with classes being not loaded in rails development mode (langalex)
* fixed persist boolean false value (bernd)

### 0.2.15
* ability to change the name of the attribute that stores the ruby class in the documents by setting JSON.create_id (lennart)
* fixed double loading issue with bundler (jweiss)
* fixed an issue with setting attachments (endor)

### 0.2.13

* support adding errors in before_validation callbacks (mattmatt)
* support for inheritance (mattmatt)
* support for save without validations (mattmatt)
* improved (de)serialization now supports deserializing nested objects (railsbros, specs by hagenburger)
* RSpec matchers for testing map/reduce functions (langalex)

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