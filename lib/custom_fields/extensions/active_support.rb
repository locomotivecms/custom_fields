unless ActiveSupport::Callbacks::ClassMethods.method_defined?(:without_callback)

  module ActiveSupport::Callbacks::ClassMethods
    def without_callback(*args, &block)
      skip_callback(*args)
      yield.tap do |result|
        set_callback(*args)
      end
    end
  end

end