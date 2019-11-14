# Serves files stored with the database service in the same way that the cloud services do.
# This means using expiring, signed URLs that are meant for immediate access, not permanent linking.
# Always go through the BlobsController, or your own authenticated controller, rather than directly
# to the service url.
class ActiveStorage::DatabaseController < ActiveStorage::BaseController
  skip_forgery_protection

  def show
    if key = decode_verified_key
      # filename = key[:disposition].match(/filename=(\"?)(.+)\1/)[2]
      # Filename and content length can be determined w/o retrieving blob record given that the entire file will be
      # read into memory (via database_service.download).  Anticipating future feature of streaming.
      blob = ActiveStorage::Blob.find_by!(key: key[:key])

      serve_file key[:key], last_modified: key[:created_at], content_length: blob.byte_size,
                 content_type: key[:content_type], disposition: key[:disposition]
    else
      head :not_found
    end
  end

  def update
    if token = decode_verified_token
      if acceptable_content?(token)
        database_service.upload token[:key], request.body, checksum: token[:checksum]
        head :no_content
      else
        head :unprocessable_entity
      end
    end
  rescue ActiveStorage::IntegrityError
    head :unprocessable_entity
  end

  private
  def database_service
    ActiveStorage::Blob.service
  end

  def decode_verified_key
    ActiveStorage.verifier.verified(params[:encoded_key], purpose: :blob_key)
  end

  def serve_file(key, last_modified:, content_length:, content_type:, disposition:)
    response.headers["Content-Type"] = content_type || DEFAULT_SEND_FILE_TYPE
    response.headers["Content-Disposition"] = disposition || DEFAULT_SEND_FILE_DISPOSITION
    response.headers["Content-Length"] = content_length if !content_length.nil?
    response.headers["Last-Modified"] = last_modified if !last_modified.nil?

    send_data database_service.download(key)
  end


  def decode_verified_token
    ActiveStorage.verifier.verified(params[:encoded_token], purpose: :blob_token)
  end

  def acceptable_content?(token)
    token[:content_type] == request.content_mime_type && token[:content_length] == request.content_length
  end
end
