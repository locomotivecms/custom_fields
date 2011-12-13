module CustomFields
  module Types
    module File

      extend ActiveSupport::Concern

      #
      # TODO
      #
      module TargetMethods

        def apply_file_custom_field(name)
          self.class.mount_uploader name, FileUploader
        end

      end

      class FileUploader < ::CarrierWave::Uploader::Base
      end

    end
  end
end