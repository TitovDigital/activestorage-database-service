#require "fileutils"
#require "pathname"
#require "digest/md5"
#require "active_support/core_ext/numeric/bytes"

module ActiveStorage
  # Wraps a database table as an Active Storage service. See ActiveStorage::Service for the generic API
  # documentation that applies to all services.
  class Service::DatabaseService < Service
    require_relative '../../../app/models/active_storage_datum'

    def initialize(**args)
    end

    def upload(key, io, checksum: nil, **)
      instrument :upload, key: key, checksum: checksum do
        ::ActiveStorageDatum.create!(key: key, io: io.read)
      end
    end

    def download(key)
      instrument :download, key: key do
        record = ::ActiveStorageDatum.find_by_key(key)
        if record
          return record.io
        else
          raise ActiveStorage::FileNotFoundError
        end
      end
    end

    def download_chunk(key, range)
      raise NotImplementedError
    end

    def delete(key)
      instrument :delete, key: key do
        ::ActiveStorageDatum.where(key: key).delete_all
      end
    end

    def exist?(key)
      instrument :exist, key: key do |payload|
        answer = ::ActiveStorageDatum.where(key: key).count > 0
        payload[:exist] = answer
        answer
      end
    end

    def url(key, expires_in:, filename:, disposition:, content_type:)
      raise NotImplementedError
    end

    def url_for_direct_upload(key, expires_in:, content_type:, content_length:, checksum:)
      raise NotImplementedError
    end

    def headers_for_direct_upload(key, content_type:, **)
      raise NotImplementedError
    end

    def path_for(key) #:nodoc:
      raise NotImplementedError
    end
  end
end
