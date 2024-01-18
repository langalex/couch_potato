## Changes

# 1.13.0

- add Ruby 3.2 support
- remove Ruby 2.7 support
- add active_support 7.1 support
- remove active_support 6.x support

# 1.12.1

- re-enable aliases when parsing config yaml file

# 1.12.0

- remove active_support 5.x
- add Ruby 3.1 support (active_support 6.1, 7.0)

# 1.11.0

- improve view_in_batches performance by switching to using startkey_docid over skip

### 1.10.1

- support passing an empty array to CouchPotato::Database#load

### 1.10.0

- add spec/support for Rails 7

### 1.9.0

- add spec/support for Rails 6.1
- add caching Couchrest connections to reduce total number created

### 1.8.0

- remove not saving model if it is not dirty. this could lead to missed document updates if the document has been updated in a different process in-between being loaded and saved in the current process.

- remove deep dirty tracking

### 1.7.1

- added support for properties of type Integer

### 1.7.0

- added `_revisions` method that returns all available revisions of a document.

### 1.6.4

- bug fix for accessing inherited properties (Alexander Lang)

### 1.6.3

- added ActiveSupport instrumentation (Alexander Lang)

### 1.6.2

- view digest bugfix (Alexander Lang)

### 1.6.1

- added option to add digests to a single view (Alexander Lang)

### 1.6.0

- added global option to add digests to view names (Alexander Lang)

### 1.5.1

- updated CouchRest to 2.0.0.rc3 in order to re-use http connections. Performance improvements. (Thilo Utke)
- added passing params to lists (Alexander Lang)

### 1.5.0

- Moved RSpec matchers into couch_potato-rspec gem. This way, people not using RSpec don't need to install the helpers, plus we can release separate matchers for RSpec 2 and 3.

### 1.4.0

- Added support for passing the model to blocks for computing the default value of a property (Alexander Lang)

### 1.3.0

- Add support for built-in couchdb reduce functions in map reduce specs (Andy Morris)
- Make specs handle CommonJS modules via module.exports as well as exports (Andy Morris)
- Changed #attributes to return a HashWithIndifferentAccess (Owen Davies)

### 1.2.0

- adds optional deep dirty tracking (andymorris)
- fixes an exception when deleting an already deleted document (Alexander Lang)

### 1.1.4

- Removes the dependency to json/add/core (cstettner)

### 1.1.3

- removes check if database exists to avoid lots of additional requests (Alexander Lang)

### 1.1.2

- fixes `CouchPotato.models` did not include subclasses
- adds `CouchPotato.use` (Daniel Lohse)
- fixes MapReduceToMatcher when reduce uses `sum` (Daniel Lohse)
- adds `CouchPotato::Config.database_host` for using multiple databases in a project (Daniel Lohse)
- makes `cast_native` cast floats with no leading digits (wrshawn)

### 1.1.1

- fixes properties were leaked to sibling classes (Alexander Lang)

### 1.1.0

- adds conflict handling for Database#save/destroy (Alexander Lang)

### 1.0.1

- fixes error when bulk loaded document does not respond to database= (Alexander Lang)

### 1.0.0

- adds `reload` method (Alexander Lang)
- removes `total_rows` from database results (Alexander Lang)
- changes `==` to use ids instead of comparing all attributes (orders of magnitude faster) ([Jochen Kramer](https://github.com/freetwix))
- fixes decoding JSON objects for newer versions of the JSON gem (Alexander Lang)
- adds support for testing map/reduce/rereduce (Andy Morris)
- fixes serializing dates in map/reduce specs (Andy Morris)
- adds support for Rails4 forbidden attributes protection (Alexander Lang)
- adds Rails4, drops 3.0/3.1 support (Alexander Lang)
- adds property default values returned by Procs (Andy Morris)
- adds suppot for BigDecimal properties (Fredrik Rubensson)
- adds support for 2.0, Rubinius, 1.9.3, drops Ruby 1.8, 1.9.2

### 0.7.1

- fixes a bug when trying to bulk-load non-existant documents

### 0.7.0

- ActiveSupport/Rails 3.2 compatibility (Alexander Lang)
- removed Object#try, String#blank? as they are part of ActiveSupport - ActiveSupport's try behaves differently than the couch potato implementation so this change might break your app (now calling a non-existant method on a non-nil raises a NoMethodError, before it did not) (Alexander Lang)
- bulk document loading (Matthias Jakel)
- multi db support (Peter Schröder)
- hash-style access to attributes (Peter Schröder)
- support for properties of type Array, e.g. :type => [User] (Peter Schröder)
- improve compatibility with state_machine (Alexander Lang)
- allow false as default value for properties (Matthias Jakel)
- support for Erlang views (Alexander Lang)
- don't crash, only warn if couchdb.yml is missing (Alexander Lang)
- use the therubyracer gem to run view specs instead of relying on a `js` executable (Alexander Lang)

### 0.6.0

- ActiveSupport/Rails 3.1 compatibility (Maximilian Mack)
- fix no such file to load with json/add/rails (Simone Carletti)

### 0.5.7

- support CouchPotato::Database#first/#first! calls when using `stub_db` from tests (langalex)
- support RSpec2 block syntax in `stub_db` (langalex)

### 0.5.6

- remove the stale parameter from a view query if it's nil, as couchdb only allows stale to be ok or update_after (langalex)

### 0.5.5

- support for split_design_documents_per_view (jweiss)
- errors now returns a Hash instead of an Array (bterkuile)
- support passing in list names as symbols in view specs (langalex)

### 0.5.4

- cast 'false' to false for boolean properties (langalex)

### 0.5.3

- added CouchPotato::Database.load! (langalex)

### 0.5.2

- added CouchPotato::Database#first and #first! methods (langalex)
- added workaround for BigCouch/Cloudant to not add null reduce functions to views (langalex)
- don't add \_attachments if there are none (langalex)

### 0.5.1

- fixed issues with tzinfo gem (Bernd Ahlers)

### 0.5.0

- time zone support (Time properties are now converted to current Time.zone) (langalex)
- lazy property initialization (performance!) (langalex)
- active_model is now the default validation framework (langalex)

### 0.4.0

- ruby 1.9.2 compatibility (langalex)
- couch potato objects now behave correctly when used as keys in Hashes (langalex)
- use as_json instead of to_s(:json), which is the rails way
- use ActiveModel dirty tracking (langalex) - this means no more "deep tracking", e.g. `user.tags << 'new_tag'; user.dirty? # false`

### 0.3.2

- support yielding to blocks on #initialize (martinrehfeld)
- support for negative numbers in Fixnum/Float properties (langalex)

### 0.3.1

- ActiveModel callbacks (kazjote)
- do not use Rails.env in initializer as it will free Rails.env for all times and in Rails 2.3.x apps it will be called too early thus always beeing development (jweiss)
- ruby 1.9.2 compatibility (langalex)
- can configure validation framework in couchdb.yml, process couchdb.yml with erb (langalex)

### 0.3.0

- support for lists (langalex)

### 0.2.32

- added persisted? and to_key for proper ActiveModel compliance (thilo)
- id setter (jhohertz-work)
- load document ids if include_documents is false (jweiss)
- persist given created_at/updated_at instead of Time.now (langalex)

### 0.2.31

- Removed requirement for validatable gem. Allows for using more uptodate versions of the library, or doesn't install it when you're using ActiveModel. (mattmatt)
- fixed callbacks of super classes were not run (langalex)

### 0.2.30

- pass in multiple keys when querying a view (langalex)

### 0.2.29

- nicer inspect() for models (mattmatt)
- fixed (re)reduce for property views wasn't working (langalex)

### 0.2.28

- fixed reloading nested classes (langalex)
- fixed constant missing error when loading models with uninitialized classes via views (langalex)
- added rspec helpers for stubbing out views (langalex)
- fixed design document names for nested model classes (svenfuchs)

### 0.2.27

- workaround for Rails apps using bundler: database name was not initialized from couchdb.yml (langalex)

### 0.2.26

- added to_s(:json) to Date and Time to be able to get properly formatted dates/times for searching with dates/times (langalex)
- all times are now stored as UTC (langalex)
- added support for Float attributes (arbovm)

### 0.2.25

- automatic view updates: when you change the definition of a view couch potato will now update the design document in the database (langalex)
- support for properties of type Date, better support for Time (langalex)
- support for default reduce count methods in custom views (jweiss)

### 0.2.24

- persistent instances can now be marked as dirty with #is_dirty (langalex)

### 0.2.23

- Couch Potato models now conform to the ActiveModel interface when ActiveModel is installed, see http://yehudakatz.com/2010/01/10/activemodel-make-any-ruby-object-feel-like-activerecord/ (langalex)
- fixed error with dirty tracking and BigDecimals (thilo)
- added the ability to use ActiveModel validations instead of validatable (martinrehfeld)

### 0.2.22

- fixed properties with default values returned default when a blank value like '' or [] was set (langalex)

### 0.2.21

- automatically set a database instance on results of CouchPotato::Database#view (langalex)
- improved auto loading of unloaded constants - can now load constants that have never been loaded before (langalex)
- raise exception on invalid parameters passed to a couchdb view query (langalex)
- when querying a view: pass in ranges as key instead of startkey/endkey, pass in plain value instead of hash with key (langalex)

### 0.2.20

- support for :boolean properties (jweiss)
- return the total_rows when querying a view (langalex)

### 0.2.19

- added conditions to views (langalex)

### 0.2.18

- set Fixnum property to nil when given a blank string (langalex)

### 0.2.17

- fixed nil attributes were omitted in json (jweiss, mattmatt)
- support for properties of type Fixnum (langalex)

### 0.2.16

- fixed problem with classes being not loaded in rails development mode (langalex)
- fixed persist boolean false value (bernd)

### 0.2.15

- ability to change the name of the attribute that stores the ruby class in the documents by setting JSON.create_id (lennart)
- fixed double loading issue with bundler (jweiss)
- fixed an issue with setting attachments (endor)

### 0.2.13

- support adding errors in before_validation callbacks (mattmatt)
- support for inheritance (mattmatt)
- support for save without validations (mattmatt)
- improved (de)serialization now supports deserializing nested objects (railsbros, specs by hagenburger)
- RSpec matchers for testing map/reduce functions (langalex)

### 0.2.10

- fixed bug with hardcoded timezone

### 0.2.9

- allow to overwrite attribute accessor of properties and use super to call the original accessors
- allow read access to attributes that are present in the Couchdb document but not defined as properties
- support default values for properties via the :default parameter
- support attachments via the \_attachments property
- support for namespaces models
- removed belongs_to macro for now
- removed CouchPotato::Config.database_server, just set CouchPotato::Config.database_name to the full url if you are not using localhost:5984
- Ruby 1.9 was broken and is now working again
