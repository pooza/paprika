module Paprika
  class PeerTubeURLNowplayingHandler < NowplayingHandler
    def create_uri(keyword)
      return PeerTubeURI.parse(keyword)
    end
  end
end
