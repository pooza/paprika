module Paprika
  class Template < Ginseng::Template
    include Package
    include SNSMethods

    def self.assign_values
      return {
        package: Package,
        env: Environment,
        crypt: Crypt,
        config:,
      }
    end
  end
end
