module Paprika
  class Environment < Ginseng::Environment
    include Package

    def self.name
      return File.basename(dir)
    end

    def self.rake?
      return ENV['RAKE'].present?
    end

    def self.test?
      return ENV['TEST'].present?
    end

    def self.type
      return config['/environment'] rescue 'development'
    end

    def self.development?
      return type == 'development'
    end

    def self.production?
      return type == 'production'
    end

    def self.dir
      return Paprika.dir
    end
  end
end
