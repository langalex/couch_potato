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

Couch Potato is hosted as a gem on gemcutter.org which you can install like this:

    sudo gem install couch_potato --source http://gemcutter.org

#### Using with your ruby application:

    require 'rubygems'
    require 'couch_potato'

Alternatively you can download or clone the source repository and then require lib/couch_potato.rb.

You MUST specify the name of the database:

    CouchPotato::Config.database_name = 'name_of_the_db'

The server URL will default to http://localhost:5984/ unless specified:

    CouchPotato::Config.database_name = "http://example.com:5984/name_of_the_db"

#### Using with Rails

Add to your config/environment.rb:

    config.gem 'couch_potato', :source => 'http://gemcutter.org'
    config.frameworks -= [:active_record] # if you switch completely

Then create a config/couchdb.yml:

    development: development_db_name
    test: test_db_name
    production: http://db.server/production_db_name

Alternatively you can also install Couch Potato directly as a plugin.

### Introduction

This is a basic tutorial on how to use Couch Potato. If you want to know all the details feel free to read the specs and the [rdocs](http://rdoc.info/projects/langalex/couch_potato).

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

Properties can be typed:

    class User
      include CouchPotato::Persistence

      property :address, :type => Address
    end
    
In this case Address also implements CouchPotato::Persistence which means its JSON representation will be added to the user document.  
Couch Potato also has support for the basic types (right now Fixnum and :boolean are supported):

    class User
      include CouchPotato::Persistence

      property :age, :type => Fixnum
      property :receive_newsletter, :type => :boolean
    end

With this in place when you set the user's age as a String (e.g. using an hTML form) it will be converted into a Fixnum automatically.
    

Properties can have a default value:

    class User
      include CouchPotato::Persistence

      property :active, :default => true
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

Couch Potato uses the validatable library for validation (http://validatable.rubyforge.org/)\

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

You can also pass conditions as a JavaScript string:

    class User
      property :name

      view :completed, :key => :name, :conditions => 'doc.completed === true'
    end

The creation of views is based on view specification classes (see [CouchPotato::View::BaseViewSpec](http://rdoc.info/rdoc/langalex/couch_potato/blob/e8f0069e5529ad08a1bd1f02637ea8f1d6d0ab5b/CouchPotato/View/BaseViewSpec.html) and its descendants for more detailed documentation). The above code uses the ModelViewSpec class which is used to find models by their properties. For more sophisticated searches you can use other view specifications (either use the built-in or provide your own) by passing a type parameter:

If you have larger structures and you only want to load some attributes you can use the PropertiesViewSpec (the full class name is automatically derived):

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

You can pass in your own view specifications by passing in :type => MyViewSpecClass. Take a look at the CouchPotato::View::*ViewSpec classes to get an idea of how this works.

#### Associations

Not supported. Not sure if they ever will be. You can implement those yourself using views and custom methods on your models.

#### Callbacks

Couch Potato supports the usual lifecycle callbacks known from ActiveRecord:

    class User
      include CouchPotato::Persistence

      before_create :do_something_before_create
      before_update {|user| user.do_something_on_update}
    end

This will call the method do_something_before_create before creating an object and run the given lambda before updating one. Lambda callbacks get passed the model as their first argument. Method callbacks don't receive any arguments.

Supported callbacks are: :before_validation, :before_validation_on_create, :before_validation_on_update, :before_validation_on_save, :before_create, :after_create, :before_update, :after_update, :before_save, :after_save, :before_destroy, :after_destroy.

If you need access to the database in a callback: Couch Potato automatically assigns a database instance to the model before saving and when loading. It is available as _database_ accessor from within your model instance.

#### Attachments

There is basic attachment support: if you want to store any attachments set that _attachments attribute of a model before saving like this:

    class User
      include CouchPotato::Persistence
    end
    
    user = User.new
    user._attachments = {'photo' => {'data' => '[image byte data]', 'content_type' => 'image/png'}}
    
When saving this object an attachment with the name _photo_ will be uploaded into CouchDB. It will be available under the url of the user object + _/photo_. When loading the user at a later time you still have access to the _content_type_ and additionally to the _length_ of the attachment:

    user_reloaded = CouchPotato.database.load user.id
    user_reloaded._attachments['photo'] # => {'content_type' => 'image/png', 'length' => 37861}

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

##### Testing map/reduce functions

Couch Potato provides custom RSpec matchers for testing the map and reduce functions of your views. For example you can do this:

    Class User
      include CouchPotato::Persistence
      
      view :by_name, :key => :name
      view :by_age, :key => :age
    end
    
    #RSpec
    require 'couch_potato/rspec/matchers'
    
    describe User, 'by_name' do
      it "should map users to their name" do
        User.by_name.should map({:name => 'bill', :age => 23}).to(['bill', null])
      end
      
      it "should reduce the users to the sum of their age" do
        User.by_age.should reduce([], [[23], [22]]).to(45)
      end
      
      it "should rereduce" do
        User.by_age.should rereduce([], [[23], [22]]).to(45)
      end
    end
    
This will actually run your map/reduce functions in a JavaScript interpreter, passing the arguments as JSON and converting the results back to Ruby. For more examples see the [spec](http://github.com/langalex/couch_potato/blob/master/spec/unit/rspec_matchers_spec.rb).

In order for this to work you must have the `js` executable in your PATH. This is usually part of the _spidermonkey_ package/port. (On MacPorts that's _spidemonkey_, on Linux it could be one of _libjs_, _libmozjs_ or _libspidermonkey_). When you installed CouchDB via your packet manager Spidermonkey should already be there.

### Helping out

Please fix bugs, add more specs, implement new features by forking the github repo at http://github.com/langalex/couch_potato.

Issues are tracked at github: http://github.com/langalex/couch_potato/issues

There is a mailing list, just write to: couchpotato@librelis.com

You can run all the specs by calling 'rake spec_unit' and 'rake spec_functional' in the root folder of Couch Potato. The specs require a running CouchDB instance at http://localhost:5984

I will only accept patches that are covered by specs - sorry.

### Contact

If you have any questions/suggestions etc. please contact me at alex at upstream-berlin.com or @langalex on twitter.
