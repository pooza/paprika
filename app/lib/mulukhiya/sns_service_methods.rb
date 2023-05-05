module Paprika
  module SNSServiceMethods
    include SNSMethods

    def update_status(id, body, params = {})
      status = status_class[id]
      values = status.values.slice(
        status_field.to_sym,
        reply_to_field.to_sym,
        spoiler_field.to_sym,
        visibility_field.to_sym,
      )
      values[attachment_field] = status.attachments.map(&:id)
      delete_status(id, params)
      if body.is_a?(Hash)
        body = values.merge(body)
      else
        body = values.merge(status_field => body.to_s)
      end
      return post(body.deep_symbolize_keys, params)
    end

    def upload(path, params = {})
      path = path.path if [File, Tempfile].map {|c| path.is_a?(c)}.any?
      if filename = params[:filename]
        dir = File.join(Environment.dir, 'tmp/media', File.read(path).sha256)
        FileUtils.mkdir_p(dir)
        file = MediaFile.new(path)
        dest = File.basename(filename, File.extname(filename))
        dest += file.recommended_extname unless dest.end_with?(file.recommended_extname)
        dest = File.join(dir, dest)
        FileUtils.copy(path, dest)
        path = dest
      end
      params.fetch(:trim_times, 0).times {ImageFile.new(path).trim!}
      return super
    ensure
      FileUtils.rm_rf(dir) if dir
    end

    def upload_remote_resource(uri, params = {})
      payload = {file: {tempfile: MediaFile.download(uri)}}
      params[:version] ||= 1
      Event.new(:pre_upload, params).dispatch(payload)
      response = upload(payload.dig(:file, :tempfile).path, params)
      Event.new(:post_upload, params).dispatch(payload)
      return response
    end

    def delete_attachment(attachment, params = {})
      attachment = attachment.id if attachment.is_a?(attachment_class)
      return super
    end

    def nodeinfo
      return super.merge(paprika: config.about)
    end

    def account
      @account ||= account_class.get(token:) rescue nil
      return @account
    end

    def access_token
      @access_token ||= access_token_class.get(token:) rescue nil
      return @access_token
    end

    def clear_oauth_client(type = :default)
      oauth_client_storage.unlink(type || :default)
    end

    def oauth_client_storage
      @oauth_client_storage ||= OAuthClientStorage.new
      return @oauth_client_storage
    end

    def create_command_uri(title)
    end

    def redis
      @redis ||= Redis.new
      return @redis
    end

    def default_token
      return account_class.test_token
    end
  end
end
