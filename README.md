# ContextExposer

Allows the Controller to exposes a Context object to the View. 
This Context object alone contains all the information passed to the View from the controller. 

No more pollution of the View with content helper methods or even worse, instance variables.

The Context object will by default be an instance of `ContextExposer::ViewContext`, but you can subclass this baseclass to add you own logic for more complex scenarios. This also allows for a more modular approach, where you can easily share or subclass logic between different view contexts. Nice!

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

HAML view example

```haml
%h1 Posts
= context.posts.each do |post|
  %h2 = post.name
```

You can also define your own subclass of `ViewContext` and designate an instance of this custom class as your "exposed" target, via  `view_context_class`method.

Example:

```ruby
class PostsController < ActionController::Base
  include ContextExposer::BaseController
  
  view_context_class :posts_view_context

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
= context.admin_posts.each do |post|
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

## Integration with decent_exposure gem

Initial integration support is included for `decent_exposure`, another popular gem with similar functionality. To add methods exposed by `decent_exposure` `#expose` to the context object, simply call `#context_expose_decently` or the alias method `#expose_decently`.

```ruby
# using gem 'decent_exposure'
# auto-included in ActionController::Base

class PostsController < ActionController::Base
  include ContextExposer::ResourceController

  expose(:posts)
  expose(:post) { Post.first}
  expose(:postal)

  context_expose_decently except: 'postal'
end
```

HAML view example

```haml
%h1 Posts
= context.posts.each do |post|
  %h2 = post.name
```

## TODO

Set up tests on dummy app ;)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
