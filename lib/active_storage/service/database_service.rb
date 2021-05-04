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
      instrument :download_chunk, key: key, range: range do
        bytes = ::ActiveStorageDatum.select("substring(io from #{range.begin} for #{range.size})").find_by_key(key)
        return bytes
      end
    end

    def delete(key)
      instrument :delete, key: key do
        ::ActiveStorageDatum.where(key: key).delete_all
      end
    end

    def delete_prefixed(prefix)
    end

    def exist?(key)
      instrument :exist, key: key do |payload|
        answer = ::ActiveStorageDatum.where(key: key).exists?
        payload[:exist] = answer
        answer
      end
    end

    def url(key, expires_in:, filename:, disposition:, content_type:)
      instrument :url, key: key do |payload|
        content_disposition = content_disposition_with(type: disposition, filename: filename)
        verified_key_with_expiration = ActiveStorage.verifier.generate(
            {
                key: key,
                disposition: content_disposition,
                content_type: content_type
            },
            expires_in: expires_in,
            purpose: :blob_key
        )

        generated_url = url_helpers.rails_database_service_url(verified_key_with_expiration,
                                                               host: current_host,
                                                               disposition: content_disposition,
                                                               content_type: content_type,
                                                               filename: filename
        )
        payload[:url] = generated_url

        generated_url
      end
    end

    def url_for_direct_upload(key, expires_in:, content_type:, content_length:, checksum:)
      instrument :url, key: key do |payload|
        verified_token_with_expiration = ActiveStorage.verifier.generate(
            {
                key: key,
                content_type: content_type,
                content_length: content_length,
                checksum: checksum
            },
            expires_in: expires_in,
            purpose: :blob_token
        )

        generated_url = url_helpers.update_rails_database_service_url(verified_token_with_expiration, host: current_host)

        payload[:url] = generated_url

        generated_url
      end
    end

    def headers_for_direct_upload(key, content_type:, **)
      { "Content-Type" => content_type }
    end

    private

    def url_helpers
      @url_helpers ||= Rails.application.routes.url_helpers
    end

    def current_host
      ActiveStorage::Current.host
    end
  end
end
