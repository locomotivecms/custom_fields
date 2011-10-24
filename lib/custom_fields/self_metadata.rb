module CustomFields

  class SelfMetadata

    include ::Mongoid::Document
    extend  CustomFields::ProxyClass::Helper
    extend  CustomFields::ProxyClass::Builder

    ## other accessors ##
    attr_accessor :association_name # missing in 2.0.0 rc

    protected

    def parentize_with_custom_fields(object)
      object_name = object.class.to_s.underscore

      self.association_name = self.metadata ? self.metadata.name : self.relations[object_name].inverse_of

      if !self.relations.key?(object_name)
        self.singleton_class.embedded_in object_name.to_sym, :inverse_of => self.association_name
      end

      parentize_without_custom_fields(object)
    end

    alias_method_chain :parentize, :custom_fields

  end

end