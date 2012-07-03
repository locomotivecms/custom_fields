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

            if rule['localized'] == true
              klass.replace_field name, ::String, true
            end

            if rule['required']
              klass.validates_presence_of name
            end
          end

        end

      end

      class FileUploader < ::CarrierWave::Uploader::Base
      end

    end

  end

end