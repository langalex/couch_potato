## Couch Potato

... is a persistence layer written in ruby for CouchDB.

### Mission

The goal of Couch Potato is to create a minimal framework in order to store and retrieve Ruby objects to/from CouchDB and create and query views.

It follows the document/view/querying semantics established by CouchDB and won't try to mimic ActiveRecord behavior in any way as that IS BAD.

Code that uses Couch Potato should be easy to test.

Lastly Couch Potato aims to provide a seamless integration with Ruby on Rails, e.g. routing, form helpers etc.

### Core Features

* persisting objects by including the CouchPotato::Persistence module
* declarative views with either custom or generated map/reduce functions
* extensive spec suite

### Installation

Couch Potato requires Ruby 1.9.

Couch Potato is hosted as a gem on github which you can install like this:

    sudo gem source --add http://gems.github.com # if you haven't already
    sudo gem install langalex-couch_potato
  
#### Using with your ruby application:

    require 'rubygems'
    gem 'langalex-couch_potato'
    require 'couch_potato'
    CouchPotato::Config.database_name = 'name of the db'
  
Alternatively you can download or clone the source repository and then require lib/couch_potato.rb. 

#### Using with Rails

Add to your config/environment.rb:

    config.gem 'langalex-couch_potato', :lib => 'couch_potato', :source => 'http://gems.github.com'

Then create a config/couchdb.yml:

    development: development_db_name
    test: test_db_name
    production: http://db.server/production_db_name

Alternatively you can also install Couch Potato directly as a plugin. 

### Introduction

This is a basic tutorial on how to use Couch Potato. If you want to know all the details feel free to read the specs.

#### Save, load objects

First you need a class.

    class User
    end

To make instances of this class persistent include the persistence module:

    class User
      include CouchPotato::Persistence
    end

If you want to store any properties you have to declare them:

    class User
      include CouchPotato::Persistence
    
      property :name
    end
  
Properties can be of any type:

    class User
      include CouchPotato::Persistence
    
      property :address, :type => Address
    end

Now you can save your objects. All database operations are encapsulated in the CouchPotato::Database class. This separates your domain logic from the database access logic which makes it easier to write tests and also keeps you models smaller and cleaner.

    user = User.new :name => 'joe'
    CouchPotato.database.save_document user # or save_document!
  
You can of course also retrieve your instance:

    CouchPotato.database.load_document "id_of_the_user_document" # => <#User 0x3075>


#### Properties

You can access the properties you declared above through normal attribute accessors.

    user.name # => 'joe'
    user.name = {:first => ['joe', 'joey'], :last => 'doe', :middle => 'J'} # you can set any ruby object that responds_to :to_json (includes all core objects)
    user._id # => "02097f33a0046123f1ebc0ebb6937269"
    user._rev # => "2769180384"
    user.created_at # => Fri Oct 24 19:05:54 +0200 2008
    user.updated_at # => Fri Oct 24 19:05:54 +0200 2008
    user.new? # => false
  
If you want to have properties that don't map to any JSON type, i.e. other than String, Number, Boolean, Hash or Array you have to define the type like this:

    class User
      property :date_of_birth, :type => Date
    end
  
The date_of_birth property is now automatically serialized to JSON and back when storing/retrieving objects.

#### Dirty tracking

CouchPotato tracks the dirty state of attributes in the same way ActiveRecord does:

    user = User.create :name => 'joe'
    user.name # => 'joe'
    user.name_changed? # => false
    user.name_was # => nil
  
You can also force a dirty state:
  
    user.name = 'jane'
    user.name_changed? # => true
    user.name_not_changed
    user.name_changed? # => false
    CouchPotato.database.save_document user # does nothing as no attributes are dirty
  

#### Object validations

Couch Potato uses the validatable library for vaidation (http://validatable.rubyforge.org/)\

    class User
      property :name
      validates_presence_of :name
    end

    user = User.new
    user.valid? # => false
    user.errors.on(:name) # => [:name, 'can't be blank']

#### Finding stuff

In order to find data in your CouchDB you have to create a view first. Couch Potato offers you to create and manage those views for you. All you have to do is declare them in your classes:

    class User
      include CouchPotato::Persistence
      property :name
    
      view :all, :key => :created_at
    end
  
This will create a view called "all" in the "user" design document with a map function that emits "created_at" for every user document.
  
    CouchPotato.database.view User.all

This will load all user documents in your database sorted by created_at.

    CouchPotato.database.view User.all(:key => (Time.now- 10)..(Time.now), :descending => true)

Any options you pass in will be passed onto CouchDB.

Composite keys are also possible:

    class User
      property :name
    
      view :all, :key => [:created_at, :name]
    end
  
The creation of views is based on view specification classes (see the CouchPotato::View) module. The above code used the ModelViewSpec class which is used to the simple find model by property searches. For more sophisticated searches you can use other view specifications (either use the built-in or provide your own) by passing a type parameter:

If you have larger structures and you only want to load some attributes you can customize the view you can use the PropertiesViewSpec (the full class name is automatically derived):

    class User
      property :name
      property :bio
    
      view :all, :key => :created_at, :properties => [:name], :type => :properties
    end
  
  CouchPotato.database.view(User.everyone).first.name # => "joe"
  CouchPotato.database.view(User.everyone).first.bio # => nil
  
You can also pass in custom map/reduce functions with the custom view spec:

    class User
      view :all, :map => "function(doc) { emit(doc.created_at, null)}", :include_docs => true, :type => :custom
    end
  
If you don't want the results to be converted into models the raw view is your friend:

    class User
      view :all, :map => "function(doc) { emit(doc.created_at, doc.name)}", :type => :raw
    end
  
When querying this view you will get the raw data returned by CouchDB which looks something like this: {'total_entries': 2, 'rows': [{'value': 'alex', 'key': '2009-01-03 00:02:34 +000', 'id': '75976rgi7546gi02a'}]}

To process this raw data you can also pass in a results filter:

    class User
      view :all, :map => "function(doc) { emit(doc.created_at, doc.name)}", :type => :raw, :results_filter => lambda {|results| results['rows'].map{|row| row['value']}}
    end

In this case querying the view would only return the emitted value for each row.

#### Associations

Not supported. Not sure if they ever will be. You can implement those yourself using views and custom methods on your models.

#### Callbacks

Couch Potato supports the usual lifecycle callbacks known from ActiveRecord:

    class User
      include CouchPotato::Persistence
    
      before_create :do_something_before_create
      after_update :do_something_else
    end

This will call the method do_something_before_create before creating an object and do_something_else after updating one. Supported callbacks are: :before_validation_on_create, :before_validation_on_update, :before_validation_on_save, :before_create, :after_create, :before_update, :after_update, :before_save, :after_save, :before_destroy, :after_destroy. You can also pass a Proc instead of a method name.

#### Testing  

To make testing easier and faster database logic has been put into its own class, which you can replace and stub out in whatever way you want:

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
    
By creating you own instances of CouchPotato::Database and passing them a fake CouchRest database instance you can completely disconnect your unit tests/spec from the database.

### Helping out

Please fix bugs, add more specs, implement new features by forking the github repo at http://github.com/langalex/couch_potato.

You can run all the specs by calling 'rake spec_unit' and 'rake spec_functional' in the root folder of Couch Potato. The specs require a running CouchDB instance at http://localhost:5984

I will only accept patches that are covered by specs - sorry.

### Contact

If you have any questions/suggestions etc. please contact me at alex at upstream-berlin.com or @langalex on twitter.
