# frozen_string_literal: true

module ESSI
  # Wrapper for Aws::S3::Client
  # See https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/S3/Client.html
  class ExternalStorageService
    attr_reader :external_storage_pool

    # @param params Hash options passed to the S3 client
    # @param pool_size Integer size of connection pool
    def initialize(params: {}, pool_size: 5)
      @external_storage_pool = ConnectionPool.new(size: pool_size) do
        Aws::S3::Client.new(params.merge(endpoint: endpoint, region: region, credentials: credentials, force_path_style: true,
                            logger: Rails.logger))
      end
      @bucket = ESSI.config.dig(:external_storage, :bucket)
      @prefix = ESSI.config.dig(:external_storage, :prefix)
    end

    # Get object info from external storage
    # @param id String identifier key e.g. 'dv13zt20x-original_file'
    # @param params Hash options passed to the S3 client
    # @return Aws::S3::Types::GetObjectOutput
    def head(id, params: {})
      @external_storage_pool.with do |client|
        client.head_object(params.merge(key: prefix_id(id), bucket: @bucket))
      end
    end

    # Get object from external storage
    # Call #body.read on the response to access file data
    # @param id String identifier key e.g. 'dv13zt20x-original_file'
    # @param params Hash options passed to the S3 client
    # @return Aws::S3::Types::GetObjectOutput
    def get(id, params: {})
      @external_storage_pool.with do |client|
        client.get_object(params.merge(key: prefix_id(id), bucket: @bucket))
      end
    end

    # @param id String identifier key e.g. 'dv13zt20x-original_file'
    # @param file File io
    # @param content_type String MIME type
    # @param params Hash options passed to the S3 client
    # @return Aws::S3::Types::PutObjectOutput
    def put(id, file, content_type: 'application/octet-stream', params: {})
      # S3 does not play well with underscores
      params[:metadata].deep_transform_keys! { |k| k.to_s.dasherize } if params[:metadata]
      md5 = Digest::MD5.file(file)
      resp = @external_storage_pool.with do |client|
        client.put_object(params.merge(key: prefix_id(id),
                          bucket: @bucket,
                          body: file,
                          content_type: content_type,
                          content_md5: md5.base64digest))
      end
      raise "Checksum mismatch in external storage response" unless md5 == resp.etag.undump
      resp
    end

    # @param params Hash options passed to the S3 client
    # @return Aws::S3::Types::ListObjectsV2Output
    def list(params: {})
      @external_storage_pool.with do |client|
        client.list_objects_v2(params.merge(bucket: @bucket))
      end
    end

    # Deletes an object from external storage
    # @param id String identifier key e.g. 'dv13zt20x-original_file'
    # @return Aws::S3::Types::DeleteObjectOutput
    def delete(id, params: {})
      @external_storage_pool.with do |client|
        client.delete_object(params.merge(key: prefix_id(id), bucket: @bucket))
      end
    end

    # Health check of external storage bucket
    # @return boolean
    def health
      @external_storage_pool.with do |client|
        client.head_bucket(bucket: @bucket).successful?
      end
    end

    def id_to_http_uri(id)
      "#{endpoint}/#{@bucket}/#{prefix_id(id)}"
    end

    def id_to_s3_uri(id)
      "s3://#{@bucket}/#{prefix_id(id)}"
    end

    def prefix_id(id)
      "#{@prefix}/#{treeify_id(id)}"
    end

    def external?(file_set)
      file_set.content_location&.start_with?('s3://') || false
    end

    def external_id(file_set)
      file_set.content_location.split('/').last if external?(file_set)
    end

    # external equivalent to Hyrax::WorkingDirectory.find_or_retrieve
    def find_or_retrieve(file_set, file_id: file_set.original_file&.id, filepath: nil)
      return filepath if filepath && File.exist?(filepath)
      if external?(file_set)
        ext_id = external_id(file_set)
        ext_resp = get(ext_id)
        filepath = Hyrax::WorkingDirectory.send(:copy_stream_to_working_directory, ext_id, ext_id, ext_resp.body)
      else
        Rails.logger.warn("External storage find_or_retrieve called for FileSet #{file_set.id} not stored externally")
        filepath = nil
      end
      return filepath
    end

  private

    def endpoint
      ESSI.config.dig(:external_storage, :url)
    end

    def region
      ESSI.config.dig(:external_storage, :region)
    end

    def treeify_id(id)
      Noid::Rails.treeify(id)
    end

    def credentials
      @credentials ||= Aws::Credentials.new(ESSI.config.dig(:external_storage, :access_key),
                                            ESSI.config.dig(:external_storage, :secret_key))
    end
  end
end
