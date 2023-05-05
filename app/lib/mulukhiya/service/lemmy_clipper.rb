require 'faye/websocket'

module Paprika
  class LemmyClipper
    include Package
    include SNSMethods

    def initialize(params = {})
      @params = params.deep_symbolize_keys
      @params[:password] = (@params[:password].decrypt rescue @params[:password])
      logger.info(clipper: self.class.to_s, method: __method__, url: uri.to_s)
    end

    def client
      @client ||= Faye::WebSocket::Client.new(uri.to_s, [], {
        tls: {
          verify_peer: verify_peer?,
          root_cert_file:,
          logger:,
        },
        ping: keepalive,
      })
      return @client
    end

    def uri
      unless @uri
        @uri = Ginseng::URI.parse("wss://#{Ginseng::URI.parse(@params[:url]).host}")
        @uri.path = config['/lemmy/urls/api']
      end
      return @uri
    end

    def keepalive
      return config['/websocket/keepalive']
    end

    def verify_peer?
      return config['/lemmy/verify_peer']
    end

    def root_cert_file
      return config['/lemmy/root_cert_file']
    rescue
      return ENV.fetch('SSL_CERT_FILE', nil)
    end

    def clip(body)
      listen(method: :post, body:)
    end

    def communities
      listen(method: :fetch_communities)
      return @communities
    end

    private

    def listen(params = {})
      EM.run do
        login

        client.on :error do |e|
          raise e.message
        end

        client.on :message do |message|
          payload = JSON.parse(message.data)
          raise 'Empty message (rate limit?)' unless payload
          raise payload['error'] if payload['error']
          method = "handle_#{payload['op']}".underscore.to_sym
          EM.stop_event_loop if send(method, payload['data'], params) == :stop
        end
      rescue => e
        e.alert(websocket: uri.to_s)
        EM.stop_event_loop
      end
    end

    def handle_login(payload, params = {})
      @jwt = payload['jwt']
      send(params[:method], params[:body])
    end

    def handle_create_post(payload, params = {})
      return :stop
    end

    def handle_list_communities(payload, params = {})
      @communities = payload['communities']
        .select {|c| c['subscribed']}
        .sort_by {|c| c.dig('community', 'id')}
        .to_h {|c| [c.dig('community', 'id'), c.dig('community', 'title')]}
      return :stop
    end

    def username
      return @params[:user]
    end

    def password
      return @params[:password].decrypt rescue @params[:password]
    end

    def login
      client.send(op: 'Login', data: {
        username_or_email: username,
        password:,
      })
    end

    def post(body = {})
      body ||= {}
      body.deep_symbolize_keys!
      raise Ginseng::AuthError, 'invalid jwt' unless @jwt
      raise Ginseng::RequestError, 'invalid community' unless @params[:community]
      data = {community_id: @params[:community], auth: @jwt, name: body[:name]&.to_s}
      if uri = create_status_uri(body[:url])
        raise Ginseng::RequestError, "URI #{uri} invalid" unless uri.valid?
        raise Ginseng::RequestError, "URI #{uri} not public" unless uri.public?
        data[:url] = uri.to_s
        data[:name] ||= uri.subject.ellipsize(config['/lemmy/subject/max_length'])
        data[:body] ||= "via: #{uri}"
      end
      client.send(op: 'CreatePost', data:)
    end

    def fetch_communities(body = {})
      body ||= {}
      body.deep_symbolize_keys!
      raise Ginseng::AuthError, 'invalid jwt' unless @jwt
      client.send(op: 'ListCommunities', data: {
        limit: config['/lemmy/communities/limit'],
        auth: @jwt,
        type_: 'Subscribed',
        sort: 'New',
        page: 1,
      })
    end
  end
end
