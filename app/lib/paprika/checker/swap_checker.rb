module Paprika
  class SwapChecker < Checker
    def ohai_plugins
      return ['platform', 'memory']
    end

    def value_freebsd
      return ohai[:memory][:swap].values.last.to_h {|k, v| [k.to_sym, v.to_i]}
    end

    def value_ubuntu
      result = ohai[:memory][:swap].to_h {|k, v| [k.to_sym, v.sub('kb', '').to_i * 1024]}
      result[:used] = result[:cached]
      return result
    end

    def usage
      return value[:used].to_f / value[:total] * 100
    end

    def warn?
      return (params[:warn] || 50) < usage
    end

    def error?
      return (params[:error] || 80) < usage
    end

    def message
      return 'usage:%.2f%%' % usage
    end
  end
end
