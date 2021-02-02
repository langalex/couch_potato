## Couch Potato

... is a persistence layer written in ruby for CouchDB.

[![Build Status](https://secure.travis-ci.org/langalex/couch_potato.png?branch=master)](http://travis-ci.org/langalex/couch_potato)

[![Dependencies](https://gemnasium.com/langalex/couch_potato.png)](https://gemnasium.com/langalex/couch_potato)

[![Code Climate](https://codeclimate.com/github/langalex/couch_potato.png)](https://codeclimate.com/github/langalex/couch_potato)


### Mission

The goal of Couch Potato is to create a minimal framework in order to store and retrieve Ruby objects to/from CouchDB and create and query views.

It follows the document/view/querying semantics established by CouchDB and won't try to mimic ActiveRecord behavior in any way as that IS BAD.

Code that uses Couch Potato should be easy to test.

Lastly Couch Potato aims to provide a seamless integration with Ruby on Rails, e.g. routing, form helpers etc.

### Core Features

* persisting objects by including the CouchPotato::Persistence module
* declarative views with either custom or generated map/reduce functions
* extensive spec suite

### Supported Environments

Check travis.yml for supported Ruby/ActiveSupport versions.

### Installation

Couch Potato is hosted as a gem which you can install like this:

```bash
gem install couch_potato
```

#### Using with your ruby application:

```ruby
require 'rubygems'
require 'couch_potato'
```

After that you configure the name of the database:

```ruby
CouchPotato::Config.database_name = 'name_of_the_db'
```

The server URL will default to `http://localhost:5984/` unless specified:

```ruby
CouchPotato::Config.database_name = "http://example.com:5984/name_of_the_db"
```

But you can also specify the database host separately from the database name:

```ruby
CouchPotato::Config.database_host = "http://example.com:5984"
CouchPotato::Config.database_name = "name_of_the_db"
```

Or with authentication

```ruby
CouchPotato::Config.database_name = "http://username:password@example.com:5984/name_of_the_db"
```

Optionally you can configure the default language for design documents (`:javascript` (default) or `:erlang`).

```ruby
CouchPotato::Config.default_language = :javascript | :erlang
```

Another switch allows you to store each CouchDB view in its own design document. Otherwise views are grouped by model.

```ruby
CouchPotato::Config.split_design_documents_per_view = true
```

If you are using more than one database from your app, you can create aliases:

```ruby
CouchPotato::Config.additional_databases = {'db1' => 'db1_production', 'db2' => 'https://db2.example.com/db'}
db1 = CouchPotato.use 'db1'
```

#### Using with Rails

Create a `config/couchdb.yml`:

```yml
default: &default
  split_design_documents_per_view: true # optional, default is false
  digest_view_names: true # optional, default is false
  default_language: :erlang # optional, default is javascript
  database_host: 'http://127.0.0.1:5984'

development:
  <<: *default
  database: development_db_name
test:
  <<: *default
  database: test_db_name
production:
  <<: *default
  database: <%= ENV['DB_NAME'] %>
  additional_databases:
    db1: db1_production
    db2: https://db2.example.com/db
```

#### Rails

Add to your `Gemfile`:

```ruby
# gem 'rails' # we don't want to load activerecord so we can't require rails
gem 'railties'
gem 'actionpack'
gem 'actionmailer'
gem 'activemodel'
gem "couch_potato"
gem 'tzinfo'
```

Note: please make sure that when you run `Date.today.as_json` in the Rails console it returns something like `2010/12/10` and not `2010-12-10` - if it does another gem has overwritten Couch Potato's Date patches - in this case move Couch Potato further down in your `Gemfile` or whereever you load it.

### Introduction

This is a basic tutorial on how to use Couch Potato. If you want to know all the details feel free to read the specs and the [rdocs](http://rdoc.info/projects/langalex/couch_potato).

#### Save, load objects

First you need a class.

```ruby
class User
end
```

To make instances of this class persistent include the persistence module:

```ruby
class User
  include CouchPotato::Persistence
end
```

If you want to store any properties you have to declare them:

```ruby
class User
  include CouchPotato::Persistence

  property :name
end
```

Properties can be typed:

```ruby
class User
  include CouchPotato::Persistence

  property :address, :type => Address
end
```

In this case `Address` also implements `CouchPotato::Persistence` which means its JSON representation will be added to the user document.
Couch Potato also has support for the basic types (right now `Integer`, `Date`, `Time` and `:boolean` are supported):

```ruby
class User
  include CouchPotato::Persistence

  property :age, :type => Integer
  property :receive_newsletter, :type => :boolean
end
```

With this in place when you set the user's age as a String (e.g. using an HTML form) it will be converted into a `Integer` automatically.


Properties can have a default value:

```ruby
class User
  include CouchPotato::Persistence

  property :active, :default => true
  property :signed_up, :default => Proc.new { Time.now }
end
```

Now you can save your objects. All database operations are encapsulated in the `CouchPotato::Database` class. This separates your domain logic from the database access logic which makes it easier to write tests and also keeps you models smaller and cleaner.

```ruby
user = User.new :name => 'joe'
CouchPotato.database.save_document user # or save_document!
```

You can of course also retrieve your instance:

```ruby
CouchPotato.database.load_document "id_of_the_user_document" # => <#User 0x3075>
```

#### Handling conflicts

CouchDB uses MVCC to detect write conflicts. If a conflict occurs when trying to update a document CouchDB returns an error. To handle conflicts easily you can save documents like this:

```ruby
CouchPotato.database.save_document user do |user|
  user.name = 'joe'
end
```

When a conflict occurs Couch Potato automatically reloads the document, runs the block and tries to save it again. Note that the block is also run before initally saving the document.

#### Caching load reqeusts

You can add a cache to a database instance to enable caching subsequent `#load` calls to the same id.
Any write operation will completely clear the cache.

```ruby
db = CouchPotato.database
db.cache = {}
db.load '1'
db.load '1' # goes to the cache instead of to the database
```

In web apps, the idea is to use a per request cache, i.e. set a new cache for every request.

#### Operations on multiple documents

You can also load a bunch of documents with one request.

```ruby
CouchPotato.database.load ['user1', 'user2', 'user3'] # => [<#User 0x3075>, <#User 0x3076>, <#User 0x3077>]
```

#### Properties

You can access the properties you declared above through normal attribute accessors.

```ruby
user.name # => 'joe'
user.name = {:first => ['joe', 'joey'], :last => 'doe', :middle => 'J'} # you can set any ruby object that responds_to :to_json (includes all core objects)
user._id # => "02097f33a0046123f1ebc0ebb6937269"
user._rev # => "2769180384"
user.created_at # => Fri Oct 24 19:05:54 +0200 2008
user.updated_at # => Fri Oct 24 19:05:54 +0200 2008
user.new? # => false
```

If you want to have properties that don't map to any JSON type, i.e. other than `String`, `Number`, `Boolean`, `Hash` or `Array` you have to define the type like this:

```ruby
class User
  property :date_of_birth, :type => Date
end
```

The `date_of_birth` property is now automatically serialized to JSON and back when storing/retrieving objects.

If you want to store an Array of objects, just pass the definiton as an Array of Dates:

```ruby
class User
  property :birthdays, :type => [Date]
end
```

#### Dirty tracking

CouchPotato tracks the dirty state of attributes in the same way ActiveRecord does:

```ruby
user = User.create :name => 'joe'
user.name # => 'joe'
user.name_changed? # => false
user.name_was # => nil
```

You can also force a dirty state:

```ruby
user.name = 'jane'
user.name_changed? # => true
user.name_not_changed
user.name_changed? # => false
CouchPotato.database.save_document user # does nothing as no attributes are dirty
```

#### Optional Deep Dirty Tracking

In addition to standard dirty tracking, you can opt-in to more advanced dirty tracking for deeply structured documents by including the `CouchPotato::DeepDirtyAttributes` module in your models. This provides two benefits:

1. Dirty checking for array and embedded document properties is more reliable, such that modifying elements in an array (by any means) or changing a property of an embedded document will make the root document be `changed?`. With standard dirty checking, the `#{property}=` method must be called on the root document for it to be `changed?`.
2. It gives more useful and detailed change tracking for embedded documents, arrays of simple values, and arrays of embedded documents.

The `#{property}_changed?` and `#{property}_was` methods work the same as basic dirty checking, and the `_was` values are always deep clones of the original/previous value. The `#{property}_change` and `changes` methods differ from basic dirty checking for embedded documents and arrays, giving richer details of the changes instead of just the previous and current values. This makes generating detailed, human friendly audit trails of documents easy.

Tracking changes in embedded documents gives easy access to the changes in that document:

```ruby
book = Book.new(:cover => Cover.new(:color => "red"))
book.cover.color = "blue"
book.cover_changed? # => true
book.cover_was # => <deep clone of original state of book.cover>
book.cover_change # => [<deep clone of original state of book.cover>, {:color => ["red", "blue"]}]
```

Tracking changes in arrays of simple properties gives easy access to added and removed items:

```ruby
book = Book.new(:authors => ["Sarah", "Jane"])
book.authors.delete "Jane"
book.authors << "Sue"
book.authors_changed? # => true
book.authors_was # => ["Sarah", "Jane"]
book.authors_change # => [["Sarah", "Jane"], {:added => ["Sue"], :removed => ["Jane"]}]
```

Tracking changes in an array of embedded documents also gives changed items:

```ruby
book = Book.new(:pages => [Page.new(:number => 1), Page.new(:number => 2)]
book.pages[0].title = "New title"
book.pages.delete_at 1
book.pages << Page.new(:number => 3)
book.pages_changed? # => true
book.pages_was # => <deep clone of original pages array>
book.pages_change[0] # => <deep clone of original pages array>
book.pages_change[1] # => {:added => [<page 3>], :removed => [<page 2>], :changed => [[<deep clone of original page 1>, {:title => [nil, "New title"]}]]}
```

For change tracking in nested documents and document arrays to work, the embedded documents **must** have unique `_id` values. This can be accomplished easily in your embedded CouchPotato models by overriding `initialize`:

```ruby
def initialize(*args)
  self._id = SecureRandom.uuid
  super
end
```

#### Object validations

Couch Potato by default uses ActiveModel for validation

```ruby
class User
  property :name
  validates_presence_of :name
end

user = User.new
user.valid? # => false
user.errors[:name] # => ['can't be blank']
```

#### Finding stuff / views / lists

In order to find data in your CouchDB you have to create a [view](http://books.couchdb.org/relax/design-documents/views) first. Couch Potato offers you to create and manage those views for you. All you have to do is declare them in your classes:

```ruby
class User
  include CouchPotato::Persistence
  property :name

  view :all, :key => :created_at
end
```

This will create a view called "all" in the "user" design document with a map function that emits "created_at" for every user document.

```ruby
CouchPotato.database.view User.all
```

This will load all user documents in your database sorted by `created_at`.

For large data sets, use batches:

```ruby
CouchPotato.database.view_in_batches(User.all, batch_size: 100) do |users|
  ...
end
```

This will query CouchDB with skip/limit until all documents have been yielded.

```ruby
CouchPotato.database.view User.all(:key => (Time.now- 10)..(Time.now), :descending => true)
```

Any options you pass in will be passed onto CouchDB.

Composite keys are also possible:

```ruby
class User
  property :name

  view :all, :key => [:created_at, :name]
end
```

You can let Couch Potato generate these map/reduce functions in Erlang, which reslts in much faster view generation:

```ruby
class User
  property :name

  view :all, :key => [:created_at, :name], :language => :erlang
end
```

So far only very simple views like the above work with Erlang.

You can also pass conditions as a JavaScript string:

```ruby
class User
  property :name

  view :completed, :key => :name, :conditions => 'doc.completed === true'
end
```

The creation of views is based on view specification classes (see [CouchPotato::View::BaseViewSpec](http://rdoc.info/rdoc/langalex/couch_potato/blob/e8f0069e5529ad08a1bd1f02637ea8f1d6d0ab5b/CouchPotato/View/BaseViewSpec.html) and its descendants for more detailed documentation). The above code uses the `ModelViewSpec` class which is used to find models by their properties. For more sophisticated searches you can use other view specifications (either use the built-in or provide your own) by passing a type parameter:

If you have larger structures and you only want to load some attributes you can use the `PropertiesViewSpec` (the full class name is automatically derived):

```ruby
class User
  property :name
  property :bio

  view :all, :key => :created_at, :properties => [:name], :type => :properties
end

CouchPotato.database.view(User.everyone).first.name # => "joe"
CouchPotato.database.view(User.everyone).first.bio # => nil

CouchPotato.database.first(User.everyone).name # => "joe" # convenience function, returns nil if nothing found
CouchPotato.database.first!(User.everyone) # would raise CouchPotato::NotFound if nothing was found
```

If you want Rails to automatically show a 404 page when `CouchPotato::NotFound` is raised add this to your `ApplicationController`:

```ruby
rescue_from CouchPotato::NotFound do
  render(:file => 'public/404.html', :status => :not_found, :layout => false)
end
```

You can also pass in custom map/reduce functions with the custom view spec:

```ruby
class User
  view :all, :map => "function(doc) { emit(doc.created_at, null)}", :include_docs => true, :type => :custom
end
```

commonJS modules can also be used in custom views:

```ruby
class User
  view :all, :map => "function(doc) { emit(null, require("views/lib/test").test)}", :lib => {:test => "exports.test = 'test'"}, :include_docs => true, :type => :custom
end
```

If you don't want the results to be converted into models the raw view is your friend:

```ruby
class User
  view :all, :map => "function(doc) { emit(doc.created_at, doc.name)}", :type => :raw
end
```

When querying this view you will get the raw data returned by CouchDB which looks something like this:

```json
{'total_entries': 2, 'rows': [{'value': 'alex', 'key': '2009-01-03 00:02:34 +000', 'id': '75976rgi7546gi02a'}]}
```

To process this raw data you can also pass in a results filter:

```ruby
class User
  view :all, :map => "function(doc) { emit(doc.created_at, doc.name)}", :type => :raw, :results_filter => lambda {|results| results['rows'].map{|row| row['value']}}
end
```

In this case querying the view would only return the emitted value for each row.

You can pass in your own view specifications by passing in `:type => MyViewSpecClass`. Take a look at the CouchPotato::View::*ViewSpec classes to get an idea of how this works.

##### Digest view names

If turned on, Couch Potato will append an MD5 digest of the map function to each view name. This makes sure (together with split_design_documents_per_view) that no views/design documents are ever updated. Instead, new ones are created. Since reindexing can take a long time once your database is larger, you want to avoid blocking your app while CouchDB is busy. Instead, you create a new view, warm it up, and only then start using it.

##### Lists

CouchPotato also supports [CouchDB lists](http://books.couchdb.org/relax/design-documents/lists). With lists you can process the result of a view query with another JavaScript function. This can be useful for example if you want to filter your results, or add some data to each document.

Defining a list works similarly to views:

```ruby
class User
  include CouchPotato::Persistence

  property :first_name
  view :with_full_name, key: first_namne, list: :add_last_name
  view :all, key: :first_name

  list :add_last_name, <<-JS
    function(head, req) {
      var row;
      send('{"rows": [');
      while(row = getRow()) {
        row.doc.name = row.doc.first_name + ' doe';
        send(JSON.stringify(row));
      };
      send(']}');
    }
  JS
end

CouchPotato.database.save User.new(first_name: 'joe')
CouchPotato.database.view(User.with_full_name).first.name # => 'joe doe'
```

You can also pass in the list at query time:

```ruby
CouchPotato.database.view(User.all(list: :add_last_name))
```

And you can pass parameters to the list:

```ruby
CouchPotato.database.view(User.all(list: :add_last_name, list_params: {filter: '*'}))
```


#### Associations

Not supported. Not sure if they ever will be. You can implement those yourself using views and custom methods on your models.

#### Callbacks

Couch Potato supports the usual lifecycle callbacks known from ActiveRecord:

```ruby
class User
  include CouchPotato::Persistence

  before_create :do_something_before_create
  before_update {|user| user.do_something_on_update}
end
```

This will call the method do_something_before_create before creating an object and run the given lambda before updating one. Lambda callbacks get passed the model as their first argument. Method callbacks don't receive any arguments.

Supported callbacks are: `:before_validation`, `:before_validation_on_create`, `:before_validation_on_update`, `:before_validation_on_save`, `:before_create`, `:after_create`, `:before_update`, `:after_update`, `:before_save`, `:after_save`, `:before_destroy`, `:after_destroy`.

If you need access to the database in a callback: Couch Potato automatically assigns a database instance to the model before saving and when loading. It is available as _database_ accessor from within your model instance.

#### Attachments

There is basic attachment support: if you want to store any attachments set the `_attachments` attribute of a model before saving like this:

```ruby
class User
  include CouchPotato::Persistence
end

data = File.read('some_file.text') # or from upload
user = User.new
user._attachments = {'photo' => {'data' => data, 'content_type' => 'image/png'}}
```

When saving this object an attachment with the name _photo_ will be uploaded into CouchDB. It will be available under the url of the user object + _/photo_. When loading the user at a later time you still have access to the _content_type_ and additionally to the _length_ of the attachment:

```ruby
user_reloaded = CouchPotato.database.load user.id
user_reloaded._attachments['photo'] # => {'content_type' => 'image/png', 'length' => 37861}
```

#### Multi DB Support

Couch Potato supports accessing multiple CouchDBs:

```ruby
CouchPotato.with_database('couch_customer') do |couch|
  couch.save @customer
end
```

Unless configured otherwise this would save the customer model to `http://127.0.0.1:5984/couch_customer`.

You can also first retrieve the database instance:

```ruby
db = CouchPotato.use('couch_customer')
db.save @customer
```

#### Testing

To make testing easier and faster database logic has been put into its own class, which you can replace and stub out in whatever way you want:

```ruby
class User
  include CouchPotato::Persistence
end

# RSpec
describe 'save a user' do
  it 'should save' do
    couchrest_db = stub 'couchrest_db',
    database = CouchPotato::Database.new couchrest_db
    user = User.new
    couchrest_db.should_receive(:save_doc).with(...)
    database.save_document user
  end
end
```

By creating your own instances of `CouchPotato::Database` and passing them a fake CouchRest database instance you can completely disconnect your unit tests/spec from the database.

For stubbing out the database couch potato offers some helpers via the `couch_potato-rspec` gem. Use version 2.x of the gem if you are on RSpec 2, use 3.x for RSpec 3.

```ruby
class Comment
  view :by_commenter_id, :key => :commenter_id
end

# RSpec
require 'couch_potato/rspec'

db = stub_db # stubs CouchPotato.database
db.stub_view(Comment, :by_commenter_id).with('23').and_return([:comment1, :comment2])

CouchPotato.database.view(Comment.by_commenter_id('23')) # => [:comment1, :comment2]
CouchPotato.database.view_in_batches(Comment.by_commenter_id('23'), batch_size: 1) # => yields [:comment1] and [:comment2]
CouchPotato.database.first(Comment.by_commenter_id('23)) # => :comment1
```

##### Testing map/reduce functions

Couch Potato provides custom RSpec matchers for testing the map and reduce functions of your views. For example you can do this:

```ruby
class User
  include CouchPotato::Persistence

  property :name
  property :age, :type => Integer

  view :by_name, :key => :name
  view :by_age,  :key => :age
  view :oldest_by_name,
    :map => "function(doc) { emit(doc.name, doc.age); }",
    :reduce => "function(keys, values, rereduce) { return Math.max.apply(this, values); }"
end

#RSpec
require 'couch_potato/rspec'

describe User, 'views' do
  it "should map users to their name" do
    User.by_name.should map(User.new(:name => 'bill', :age => 23)).to(['bill', 1])
  end

  it "should reduce the users to the sum of their age" do
    User.by_age.should reduce([], [23, 22]).to(45)
  end

  it "should map/reduce users to the oldest age by name" do
    docs = [User.new(:name => "John", :age => 25), User.new(:name => "John", :age => 30), User.new(:name => "Jane", :age => 20)]
    User.oldest_by_name.should map_reduce(docs).with_options(:group => true).to(
      {"key" => "John", "value" => 30}, {"key" => "Jane", "value" => 20})
  end
end
```

This will actually run your map/reduce functions in a JavaScript interpreter, passing the arguments as JSON and converting the results back to Ruby. `map_reduce` specs map the input documents, reduce the emitted keys/values, and rereduce the results while also respecting the `:group` and `:group_level` couchdb options. For more examples see the [spec](http://github.com/langalex/couch_potato/blob/master/spec/unit/rspec_matchers_spec.rb).

In order for this to work you must have the `js` executable in your PATH. This is usually part of the _spidermonkey_ package/port. (On MacPorts that's _spidemonkey_, on Linux it could be one of _libjs_, _libmozjs_ or _libspidermonkey_). When you installed CouchDB via your packet manager Spidermonkey should already be there.

### Helping out

Please fix bugs, add more specs, implement new features by forking the github repo at http://github.com/langalex/couch_potato.

Issues are tracked at github: http://github.com/langalex/couch_potato/issues

There is a mailing list, just write to: couchpotato@librelist.com

You can run all the specs by calling 'rake spec_unit' and 'rake spec_functional' in the root folder of Couch Potato. The specs require a running CouchDB instance at `http://localhost:5984`

I will only accept patches that are covered by specs - sorry.

### Contact

If you have any questions/suggestions etc. please contact me at alex at upstream-berlin.com or @langalex on twitter.
