module DecoratesBeforeRendering
  class FindModelError < StandardError; end

  def render *args
    __auto_decorate_exposed_ones_
    super(*args)
  end

  def __auto_decorate_exposed_ones_
    __decorate_ivars__
    __decorate_exposed_ones_
  rescue StandardError => e
    logger.error 'decorates_before_render: auto_decorate error: #{e}'
  end

  def __exposed_ones_
    @__exposed_ones_ = []
    if respond_to? :_exposures
      @__exposed_ones_ << _exposures.keys
    end
    if respond_to? :_exposure_hash      
      @__exposed_ones_ << _exposure_hash.keys
    end
  end

  def __decorate_exposed_ones_
    __exposed_ones_.each do |name|
      decorator = __decorator_for__(name)
      decorator.decorate(name) if decorator
    end
  end

  def __decorator_for__(name)
    __decorator_name_for__(name).constantize
  rescue FindModelError => e
    nil
  end

  def __decorator_name_for__(name)
    "#{__model_name_for__(name)}Decorator"
  end

  def __model_name_for__(name)
    if name.respond_to?(:model_name)
      source = name
    elsif ivar.class.respond_to?(:model_name)
      source = ivar.class
    else
      raise FindModelError, "#{name} does not have an associated model"
    end

    source.model_name
  end  

  def __decorate_ivars__
    if respond_to? :__decorates__
    return if (__decorates__.nil? || __decorates__.empty?) and
              (__decorates_collection__.nil? || __decorates_collection__.empty?)

    if !__decorates__.nil?
      __decorate_ivar_names__(__decorates__) do |ivar_name, ivar, options|
        decorator = options.key?(:with) ? options.fetch(:with) : __decorator_for__(ivar)
        if decorator
          decorated = decorator.decorate(ivar) 
          instance_variable_set(ivar_name, decorated)
        end
      end
    end

    if !__decorates_collection__.nil?
      __decorate_ivar_names__(__decorates_collection__) do |ivar_name, ivar, options|
        decorated = options.fetch(:with).decorate_collection(ivar)
        instance_variable_set(ivar_name, decorated) if decorated
      end
    end
  end
end