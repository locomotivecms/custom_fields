module CustomFields
  module Types
    module File

      extend ActiveSupport::Concern

      #
      # TODO
      #
      module TargetMethods

        def apply_file_custom_field(name, accessors_module)
          unique_name = "#{name}_#{self._id}"

          if !self.class.method_exists?('uploaders') || self.class.uploaders.key?(unique_name)
            self.class.mount_uploader unique_name, FileUploader
          end

          accessors_module
        end

      end

      class FileUploader < ::CarrierWave::Uploader::Base
      end

    end
  end
end