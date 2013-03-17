module DecoratesBeforeRendering  
  class FindModelError < StandardError; end
  class DecoratorError < StandardError; end

  def render *args
    __auto_decorate_exposed_ones_
    super(*args)
  end

  def __auto_decorate_exposed_ones_
    __decorate_ivars__
    __decorate_exposed_ones_
    __decorate_ctx_exposed_ones_    
  rescue StandardError => e
    __handle_decorate_error_(e)
  end

  def __handle_decorate_error_ e 
    # puts "Error: #{e}"

    if defined?(::Rails) && (Rails.respond_to? :logger)
      Rails.logger.warn 'decorates_before_render: auto_decorate error: #{e}'
    end
  end

  def __exposed_ones_
    return [] unless self.class.respond_to? :_exposures
    @__exposed_ones_ ||= self.class._exposures.keys
  end

  def __ctx_exposed_ones_
    return [] unless self.class.respond_to? :_exposure_storage
    @__ctx_exposed_ones_ ||= self.class._exposure_storage.keys
  end

  def __decorate_exposed_ones_
    __exposed_ones_.each do |name|
      ivar_name = "@#{name}"
      obj = send(name)
      decorated = __attempt_to_decorate_(obj)

      decorated = case objs
      when Array
        __attempt_to_decorate_list_ objs        
      else
        __attempt_to_decorate_ objs
      end

      send(:instance_variable_set, ivar_name, decorated)  # if decorated
    end
  end

  def __decorate_ctx_exposed_ones_
    __ctx_exposed_ones_.each do |name|
      ivar_name = "@#{name}"
      objs = ctx.send(name)

      decorated = case objs
      when Array
        __attempt_to_decorate_list_ objs        
      else
        __attempt_to_decorate_ objs
      end

      ctx.send(:instance_variable_set, ivar_name, decorated) # if decorated
    end
  end

  def __attempt_to_decorate_list_ objs
    [objs].flatten.compact.map do |obj|
      __attempt_to_decorate_(obj)      
    end    
  end

  def __attempt_to_decorate_ obj
    if obj
      src = __src_for__(obj)
      decorator = __normalized_decorator_for__(src)
      __do_decoration_ decorator, obj
    end
  end    

  def __do_decoration_ decorator, obj
    return if !decorator || !obj
    __validate_decorator!(decorator)
    decorator.decorate(obj)
  end


  def __validate_decorator! decorator
    unless decorator.respond_to? :decorate
      raise DecoratorError, "Decorator: #{decorator} must have a #decorate method"
    end
  end

  def __decorate_error! decorator
    raise DecoratorError, "Decorator: #{decorator} must have a #decorate method"
  end

  def __src_for__ obj
    case obj
    when Class
      obj.class
    else 
      obj      
    end
  end    

  def __normalized_decorator_for__(obj)
    decorator = __decorator_for__(obj)

    case decorator
    when String
      decorator.constantize.new obj
    when Class
      decorator.new obj
    else
      decorator
    end
  end    

  def __decorator_for__(obj)
    return obj.decorator(self) if obj.respond_to? :decorator
      __decorator_name_for__(obj).constantize
  rescue FindModelError => e
    nil
  end

  def __decorator_name_for__(obj)
    "#{__model_name_for__(obj)}Decorator"
  end

  def __model_name_for__(obj)
    return obj.model_name if obj.respond_to?(:model_name)
    raise FindModelError, "#{obj} does not have an associated model"
  end  

  def __decorate_ivars__
    __validate_decorates_present_
    return if __decorates_blank?
    __decorates__ivars
    __decorates_collection_ivars__
  end

  def __validate_decorates_present_
    unless __has_decorates?
      raise "Internal method '__decorates__' not found. You need to include the 'decorates_before_render' gem " 
    end
  end

  def __has_decorates?
    respond_to?(:__decorates__)
  end

  def __decorates_blank?
    __decorates__.blank? and __decorates_collection__.blank?
  end

  def __decorates_collection_ivars__
    if !__decorates_collection__.nil?
      __decorate_ivar_names__(__decorates_collection__) do |ivar_name, ivar, options|
        decorated = options.fetch(:with).decorate_collection(ivar)
        instance_variable_set(ivar_name, decorated) if decorated
      end
    end
  end

  def __decorates__ivars
    if !__decorates__.nil?
      __decorate_ivar_names__(__decorates__) do |ivar_name, ivar, options|
        decorator = options.key?(:with) ? options.fetch(:with) : __decorator_for__(ivar)
        if decorator
          decorated = __do_decoration_(decorator, ivar)
          instance_variable_set(ivar_name, decorated)
        end
      end
    end
  end   
end 