module Paprika
  class Server < Ginseng::Web::Sinatra
    include Package
    set :root, Environment.dir

    get '/check/:name' do
      @renderer.message = params[:name]
      return @renderer.to_s
    end
  end
end
