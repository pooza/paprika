module Paprika
  class Checker
    attr_reader :params

    def initialize(params = {})
      @params = params
    end

    def ohai_plugins
      return ['platform']
    end

    def ohai
      unless @ohai
        @ohai = Ohai::System.new
        @ohai.all_plugins(ohai_plugins)
      end
      return @ohai
    end

    def value
      case platform
      when 'freebsd'
        return value_freebsd
      when 'ubuntu'
        return value_ubuntu
      else
        raise "unavailable platform '#{platform}'"
      end
    rescue => e
      return e.message
    end

    def value_freebsd
      raise Ginseng::ImplementError, "'#{__method__}' not implemented"
    end

    def value_ubuntu
      raise Ginseng::ImplementError, "'#{__method__}' not implemented"
    end

    def warn?
      raise Ginseng::ImplementError, "'#{__method__}' not implemented"
    end

    def error?
      raise Ginseng::ImplementError, "'#{__method__}' not implemented"
    end

    def result
      line = []
      if error?
        line.push('ERROR')
      elsif warn?
        line.push('WARN')
      else
        line.push('OK')
      end
      line.push(message)
      return line.join(' ')
    rescue => e
      return "EXCEPTION: #{e.message}"
    end

    def platform
      return ohai[:platform]
    end

    def self.create(name, params = {})
      return "Paprika::#{name.to_s.sub(/_checker$/, '').camelize}Checker".constantize.new(params)
    rescue => e
      e.log(name:)
      return nil
    end
  end
end
