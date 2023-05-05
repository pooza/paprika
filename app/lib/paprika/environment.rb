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

    def self.route
      return {'/' => controller_class}.merge(
        YAML.load_file(File.join(dir, 'config/route.yaml')).to_h do |entry|
          [entry['path'], entry['class'].constantize]
        end,
      )
    end
  end
end
