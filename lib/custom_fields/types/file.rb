module CustomFields

  module Types

    module File

      module Field; end

      module Target

        extend ActiveSupport::Concern

        module ClassMethods

          # Adds a file field (using carrierwave)
          #
          # @param [ Class ] klass The class to modify
          # @param [ Hash ] rule It contains the name of the field and if it is required or not
          #
          def apply_file_custom_field(klass, rule)
            name = rule['name']

            klass.mount_uploader name, FileUploader
            klass.field :"#{name}_size", type: ::Hash, default: {}

            if rule['localized'] == true
              klass.replace_field name, ::String, true
            end

            if rule['required']
              # FIXME: previously, we called "klass.validates_presence_of name"
              # but it didn't work well with localized fields.
              klass.validate do |object|
                UploaderPresenceValidator.new(object, name).validate
              end
            end
          end

          # Build a hash storing the url for a file custom field of an instance.
          #
          # @param [ Object ] instance An instance of the class enhanced by the custom_fields
          # @param [ String ] name The name of the file custom field
          #
          # @return [ Hash ] field name => url or empty hash if no file
          #
          def file_attribute_get(instance, name)
            if instance.send(:"#{name}?") #"
              value = instance.send(name.to_sym).url
              { name => value, "#{name}_url" => value }
            else
              {}
            end
          end

          # Set the value for the instance and the file field specified by
          # the 2 params.
          #
          # @param [ Object ] instance An instance of the class enhanced by the custom_fields
          # @param [ String ] name The name of the file custom field
          # @param [ Hash ] attributes The attributes used to fetch the values
          #
          def file_attribute_set(instance, name, attributes)
            [name, "remote_#{name}_url", "remove_#{name}"].each do |_name|
              self.default_attribute_set(instance, _name, attributes)
            end.compact
          end

        end

      end

      class UploaderPresenceValidator

        def initialize(document, name)
          @document, @name = document, name
        end

        def validate
          if @document.send(@name).blank?
            @document.errors.add(@name, :blank)
          end
        end

      end

      class FileUploader < ::CarrierWave::Uploader::Base

        process :set_size_in_model

        def filename
          if original_filename && model.fields[mounted_as.to_s].localized?
            _original_filename, extension = original_filename.split('.')
            ["#{_original_filename}_#{::Mongoid::Fields::I18n.locale}", extension].compact.join('.')
          else
            original_filename
          end
        end

        def set_size_in_model
          size_field_name = :"#{mounted_as}_size"

          if model.respond_to?(size_field_name)
            is_localized  = model.fields[mounted_as.to_s].options[:localize]
            key           = is_localized ? ::Mongoid::Fields::I18n.locale.to_s : 'default'
            values        = model.send(size_field_name)

            values[key] = file.size
          end
        end

      end

    end

  end

end
