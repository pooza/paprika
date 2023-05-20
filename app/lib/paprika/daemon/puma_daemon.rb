module Paprika
  class PumaDaemon < Ginseng::Daemon
    include Package

    def command
      return Ginseng::CommandLine.new([
        'puma',
        '--config', initializer_path
      ])
    end

    def motd
      return [
        `puma -V`.chomp,
        "Root URL: #{root_uri}",
        ('Ruby YJIT: Ready' if jit_ready?),
      ].compact.join("\n")
    end

    def root_uri
      unless @uri
        @uri = Ginseng::URI.new
        @uri.host = Environment.hostname
        @uri.scheme = 'http'
        @uri.port = config['/puma/port']
      end
      return @uri
    end

    def initializer_path
      return File.join(Environment.dir, 'app/initializer/puma.rb')
    end
  end
end
