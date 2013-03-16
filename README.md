# ContextExposer

Allows the Controller to exposes a Context object to the View. 
This Context object alone contains all the information passed to the View from the controller. 

No more pollution of the View with content helper methods or even worse, instance variables.

The Context object will by default be an instance of `ContextExposer::ViewContext`, but you can subclass this baseclass to add you own logic for more complex scenarios. This also allows for a more modular approach, where you can easily share or subclass logic between different view contexts. Nice!

The gem comes with integrations ready for easy migration or symbiosis with existing strategies (and gems), such as:

* exposing of instance variables (Rails default strategy)
* decent_exposure gem (expose methods)
* decorates_before_rendering gem (expose decorated instance vars)

For more on integration (and migration path) see below ;)

## Installation

Add this line to your application's Gemfile:

    gem 'context_exposer'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install context_exposer

## Usage

Use the `exposed` method which takes a name of the method to be created on the ViewContext and a block with the logic.

Example:

```ruby
class PostsController < ActionController::Base
  include ContextExposer::BaseController
  
  exposed(:post)  { Post.find params[:id] }
  exposed(:posts) { Post.find params[:id] }
end
```

The view will have the methods exposed and available on the `ctx` object.

HAML view example

```haml
%h1 Posts
= ctx.posts.each do |post|
  %h2 = post.name
```

## Macros

You can also choose to use the class macros made available on `ActionController::Base` as Rails loads.

Use `:base` or `resource` or your custom extension to include the ContextExposer controller module of your choice. The macro `context_exposer :base` is equivalent to writing `include ContextExposer::BaseController`

```ruby
class PostsController < ActionController::Base
  context_exposer :base
```

## Sublclassing and customizing the ViewContext

You can also define your own subclass of `ViewContext` and designate an instance of this custom class as your "exposed" target, via  `view_ctx_class`method.
You can also override the class method of the same name for custom class name construction behavior ;)

Example:

```ruby
class PostsController < ActionController::Base
  include ContextExposer::BaseController
  
  view_ctx_class :posts_view_context

  exposed(:post)  { Post.find params[:id] }
  exposed(:posts) { Post.all }
end
```

```ruby
class PostsViewContext < ContextExposer::ViewContext
  def initialize controller
    super
  end

  def total
    posts.size
  end

  def admin_posts
    return [] unless admin?
    posts.select {|post| post.admin? }
  end

  protected

  def current_user
    controller.current_user
  end

  def admin?
    current_user.admin?
  end  
end
```

HAML view example

```haml
%h1 Admin Posts
= ctx.admin_posts.each do |post|
  %h2 = post.name
```


This opens up some amazing possibilities to really put the logic where it belongs.The custom ViewContext would benefit from having the "admin" and "user" logic extracted either to separate modules or a custom ViewContext base class ;)

This approach opens up many new exciting ways to slice and dice your logic in a much better way, a new *MVC-C* architecture, the extra "C" for *Context*.

### ResourceController

The `ResourceController` automatically sets up the typical singular and plural-form resource helpers.

This simplifies the above `PostsController` example to this:

```ruby
class PostsController < ActionController::Base
  include ContextExposer::ResourceController
end
```

`ResourceController`  uses the following internal logic for its default functionality. You can override these methods to customize your behavior as needed.

```ruby
module ContextExposer::ResourceController
  # ...

  protected

  def resource_id
    params[:id]
  end

  def find_single_resource
    self.class._the_resource.find resource_id
  end

  def find_all_resources
    self.class._the_resource.all
  end
```

## Integrations with other exposure gems and patterns

You can use the class macro `integrate_with(name)` to integrate with either:

* decent_exposure - `integrate_with :decent_exposure`
* decorates_before_rendering - `integrate_with :decorates_before`
* instance vars - `integrate_with :instance_vars`

Note: You can even integrate with multiple startegies

`integrate_with :decent_exposure, :instance_vars`

You can also specify your integrations directly as part of your `context_exposer` call.

`context_exposer :base, with: :decent_exposure`

In case you use the usual (default) Rails pattern of passing instance variables, you can slowly migrate to exposing via `ctx` object, by adding a simple macro `context_expose :instance_vars` to your controller.

For decorated instance variables (see `decorates_before_rendering` gem), similarly use `context_expose :decorated_instance_vars`.

All of these `context_expose :xxxx` methods can optionally take an `:except` or `:only` option with a list of keys, similar to a `before_filter`.

The method `context_expose :decorated_instance_vars` can additionally take a `:for`option of either `:collection` or `:non_collection` to limit the type of instance vars exposed.

`context_expose` integration

* :instance_vars
* :decorated_instance_vars
* :decently

Here is a full example demonstrating integration with `decent_exposure`.

```ruby
# using gem 'decent_exposure'
# auto-included in ActionController::Base

class PostsController < ActionController::Base
  # make context_expose_decently method available
  context_exposer :base, with :decent_exposure

  expose(:posts)  { Post.all.order(:created_at, :asc) }
  expose(:post)   { Post.first}
  expose(:postal) { '1234' }

  # mirror all methods exposed via #expose on #ctx object 
  # except for 'postal' method
  context_expose :decently except: 'postal'
end
```

HAML view example

```haml
%h1 Posts
= ctx.posts.each do |post|
  %h2 = post.name
```

## Decorates before rendering

A patch for the `decorates_before_render` gem is currently made available.

`ContextExposer.patch :decorates_before_render`

Use this in an initializer. This way, decorates_before_render should try to decorate all your exposed variables before rendering, whether your view context is exposed as instance vars, methods or on the `ctx` object ;)

Note: This is still an experimental feature.

## Testing

The tests have been written in rspec 2 and capybara. 
The test suite consists of:

* Full app tests
* Units tests

### Dummy app feature tests

A Dummy app has been set up for use with Capybara feature testing.
Please see: http://alindeman.github.com/2012/11/11/rspec-rails-and-capybara-2.0-what-you-need-to-know.html

The feature tests can be found in `spec/app`

`$ bundle exec rspec spec/context_exposer`

### Unit tests (specs)

The unit tests can be found in `spec/context_exposer`

`$ bundle exec rspec spec/context_exposer`

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
