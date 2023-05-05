module Paprika
  module Mastodon
    class User < Sequel::Model(:users)
      many_to_one :account
    end
  end
end
