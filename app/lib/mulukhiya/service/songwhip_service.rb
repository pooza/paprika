module Paprika
  class SongwhipService
    include Package

    def initialize
      @http = HTTP.new
      @http.base_uri = config['/songwhip/urls/api']
    end

    def get(uri, params = {})
      response = @http.post('/', {
        body: {url: uri.to_s},
      })
      return response if params[:raw]
      return Ginseng::URI.parse(response['url'])
    rescue => e
      e.log(url: uri.to_s)
      return nil
    end
  end
end
