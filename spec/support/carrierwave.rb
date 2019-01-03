require 'carrierwave/test/matchers'

CarrierWave.configure do |config|
  if !ENV['GOOGLE_STORAGE_BUCKET'].nil?
    require 'carrierwave-google-storage'

    # Google Cloud Storage
    config.storage                             = :gcloud
    config.gcloud_bucket                       = ENV['GOOGLE_STORAGE_BUCKET']
    config.gcloud_bucket_is_public             = true
    config.gcloud_authenticated_url_expiration = 600

    # FIXME: we don't want people to download automatically files when they click on it
    # config.gcloud_content_disposition = 'attachment'

    config.gcloud_attributes = {
      expires: 600
    }

    config.gcloud_credentials = {
      gcloud_project: ENV['GOOGLE_STORAGE_PROJECT_ID'],
      gcloud_keyfile: File.join(File.dirname(__FILE__), '..', '..', 'gcp-keyfile.json')
    }

    # Used in production
    module CarrierWave
      module Storage
        class Gcloud < Abstract
          def identifier
            uploader&.filename rescue nil
          end
        end
      end
    end

  else
    config.storage   = :file
    config.store_dir = 'uploads'
    config.cache_dir = 'cache'
    config.root      = File.join(File.dirname(__FILE__), '..', 'tmp')
  end
end

module FixturedFile
  def self.open(filename)
    File.new(self.path(filename))
  end

  def self.path(filename)
    File.join(File.dirname(__FILE__), '..', 'fixtures', filename)
  end

  def self.duplicate(filename)
    dst = File.join(File.dirname(__FILE__), '..', 'tmp', filename)
    FileUtils.cp self.path(filename), dst
    dst
  end

  def self.reset!
    FileUtils.rm_rf(File.join(File.dirname(__FILE__), '..', 'tmp'))
    FileUtils.mkdir(File.join(File.dirname(__FILE__), '..', 'tmp'))
  end
end

FixturedFile.reset!
