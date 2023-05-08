module Paprika
  extend Rake::DSL

  namespace :paprika do
    [:puma].each do |ns|
      namespace ns do
        [:start, :stop].freeze.each do |action|
          desc "#{action} #{ns}"
          task action do
            ENV['RUBY_YJIT_ENABLE'] = '1' if Paprika::Config.instance['/ruby/jit']
            sh "#{File.join(Paprika::Environment.dir, 'bin', "#{ns}_daemon.rb")} #{action}"
          rescue => e
            warn "#{e.class} #{ns}:#{action} #{e.message}"
          end
        end

        desc "restart #{ns}"
        task restart: [:stop, :start]
      end
    end
  end

  [:start, :stop, :restart].each do |action|
    desc "#{action} all"
    multitask action => [
      "paprika:puma:#{action}",
    ]
  end
end
