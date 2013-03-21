# ContextExposer

Allows the Controller to exposes a Context object to the View. 
This Context object alone contains all the information passed to the View from the controller. 

No more pollution of the View with content helper methods or even worse, instance variables.

The Context object will by default be an instance of `ContextExposer::ViewContext`, but you can subclass this baseclass to add you own logic for more complex scenarios. This also allows for a more modular approach, where you can easily share or subclass logic between different view contexts. Nice!

The gem comes with integrations ready for easy migration or symbiosis with existing strategies (and gems), such as:

* exposing of instance variables (Rails default strategy)
* decent_exposure gem (expose methods)
* decorates_before_rendering gem (expose decorated instance vars)
* draper

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

You can also have the exposed methods automatically cache the result in an instance variable, by using the `expose_cached` variant.

```ruby
class PostsController < ActionController::Base
  include ContextExposer::BaseController
  
  expose_cached(:post)  { Post.find params[:id] }
  expose_cached(:posts) { Post.find params[:id] }
end
```

This is especially useful if used in combination with `decorates_before_rendering`, which only works on cached objects.

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

  # One model instance
  exposed(:post)        { Post.find params[:id] } 

  # Relation (for further scoping or lazy load)
  exposed(:posts)       { Post.all } 

  # Array of model instances
  exposed(:post_list)   { Post.all.to_a } 
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

The `ResourceController` automatically sets up the typical singular and plural-form resource helpers. For example for PostsController:

* `post` - one Post instance
* `posts` - Search Relatation (for lazy load or further scoping)
* `post_list` - Array of Post instances

This simplifies the above `PostsController` example to this:

```ruby
class PostsController < ActionController::Base
  # alternatively: context_exposer :resource
  include ContextExposer::ResourceController

  expose_resources :all
end
```

The macro `expose_resources` optionally takes a list of the types of resource you want to expose. Valid types are `:one`, `:many` and `:list` respectively (for fx: `post`, `posts` and `post_list`).

`ContextExposer::ResourceController`  uses the following internal logic for its default functionality. You can override these methods to customize your behavior as needed.

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

Tip: You can create reusable module and then include your custom ResourceController.

```ruby
module NamedResourceController
  extend ActiveSupport::Concern
  include ContextExposer::ResourceController

  protected

  def resource_id
    params[:name]
  end
end
```

```ruby
class PostsController < ActionController::Base
  include NamedResourceController
end

Tip: If you put your module inside the `ContextExposer` namespace, you can even use the `context_exposer` macro ;)

## Integrations with other exposure gems and patterns

You can use the class macro `integrate_with(name)` to integrate with either:

* decent_exposure - `integrate_with :decent_exposure`
* decorates_before_rendering - `integrate_with :decorates_before`
* instance vars - `integrate_with :instance_vars`

Note: You can even integrate with multiple strategies

`integrate_with :decent_exposure, :instance_vars`

You can also specify your integrations directly as part of your `context_exposer` call (recommended)

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

## Draper

The `draper` gem adds a `decorates_assigned` method since version *1.1* (see [pull request](https://github.com/drapergem/draper/pull/461)).

```ruby
decorates_assigned :article, with: FancyArticleDecorator
decorates_assigned :articles, with: PaginatingCollectionDecorator
```

Since this functionality is very similar to fx `decent_exposure`, it can be used with `ctx` in a similar way. Simply use the `context_expose_assigned` like the `context_expose_decently` macro.

`context_expose_assigned`

`context_expose_assigned only: %w{post posts}

## Decorates before rendering

A patch for the `decorates_before_render` gem is currently made available.

`ContextExposer.patch :decorates_before_rendering`

You typically use this in a Rails initializer. This way, `decorates_before_rendering` should try to decorate all your exposed variables before rendering, whether your view context is exposed as instance vars, methods or on the `ctx` object of the view ;)

Note: You can now also use the macro `decorates_before_render` to include the `DecoratesBeforeRendering` module.

### Auto-finding a decorator

For the patched version of `decorates_before_render` to work, your exposed and cached object must either have a `model_name` method that returns the name of the model name to be used to calculate the decorator name to use, or alternatively (and with higher precedence if present), a `decorator` method that takes the controller (self) as an argument and returns the full name of the decorator to use ;)

Example:

```ruby
class PostsController < ActionController::Base
  decorates_before_render
  context_exposer :base, with :decent_exposure

  expose_cached(:first_post) { Post.first } 

  protected

  def admin?
    @admin ||= current_user.admin?
  end
end
```

```ruby
class Post < ActiveRecord::Base
  def decorator contrl
    contrl.send(:admin?) ? 'Admin::PostDecorator' : model_name      
  end
end

### Auto-detection Error handling

If the auto-decoration can't find a decorator for an exposed variable (or method), it will either ignore it (not decorate it) or call `__handle_decorate_error_(error)` which by default will log a Rails warning. Override this error handler as it suits you.

## Globalizing the page context

As you have the `ctx` object encapsulate all the view state in one place, you can simplify
your partial calls to `render partial: 'my/partial/template', locals: {ctx: ctx}`.
However, if you use nested partials it quickly feels repetitive...

Which is why this pattern is now encapsulated in the view helper `render_ctx` which auto-populates the `:locals` hash with a local `page_context` variable that points to a `ContextExposer::PageContext.instance` which contains the `ctx` object :)

Furthermore, a delegation of `ctx` to  `page_context.ctx` is defined so you can still access `ctx` directly from within the views.

So you then only have to use the locals hash if you want to pass on variables not part of `ctx`.

```ruby
render_ctx partial: 'my/partial/template'
```

### Page object

To further help in making page rendering decissions, a `ContextExposer::Page` instance is 
created and populated on each request, which can contain the following data:

`:name, :id, :action, :mode, :controller_name, :type, :resource`

The Page instance will attempt to calculate the resource name from the `normalized_resource_name` method of the `ContextExposer::BaseController`. Override this method to calculate a custom resource name for the controller.

The page name will normally be calculated by concatenating action, resource name and type, so a `PostController#show` action will have the default name `'show_post_item'`. Resource `type` is either `:list` or `:item` and will be attempted calculated using the action name and looking up in the `list_actions` and `item_actions` class methods on the controller.

By default these methods will use the `base_list_actions` (index) and `base_item_actions` (show, new, edit). You can override/extend these conventions and provide your own `list_actions` and `item_actions` class methods for each controller. Macros are provided to generate these methods from a simple list.

```ruby
class Admin::BirdLocationController < ActionController::Base
  # expose, decorate etc left out

  # use macros to configure extra REST-like actions
  list_actions :manage
  item_actions :map

  # custom page object config just before render
  after_filter :set_page_mode

  # manage many birds
  def manage
    Bird.all
  end

  # show a single bird location on the map
  def map
    Bird.find params[:id]
  end

  protected

  def set_page_mode
    ctx.page.mode = mode
  end

  # custom calculated page name using fx action_name method and params etc
  def page_name
    "#{action_name}_#{mode}"
  end

  # map, details or normal mode ?
  def mode
    params[:mode]
  end

  def self.normalized_resource_name
    :bird
  end
end
```

## Testing

The tests have been written in rspec 2 and capybara. 
The test suite consists of:

* Full app tests
* Units tests

### Dummy app feature tests

A Dummy app has been set up for use with Capybara feature testing.
Please see: http://alindeman.github.com/2012/11/11/rspec-rails-and-capybara-2.0-what-you-need-to-know.html

The feature tests can be found in `spec/app`

run:

`$ bundle exec rspec spec/app`

* posts_spec - basic functionality
* items_spec - cached resource
* animals_spec - Draper decorator integration

TODO:

- Many more app integration tests are needed :P

### Unit tests (specs)

The unit tests can be found in `spec/context_exposer`

`$ bundle exec rspec spec/context_exposer`

TODO:

- Many more unit tests are needed :P

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
