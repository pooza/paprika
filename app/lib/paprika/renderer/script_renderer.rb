module Paprika
  class ScriptRenderer < Ginseng::Web::ScriptRenderer
    include Package
    attr_reader :name

    def dir
      return File.join(environment_class.dir, 'public/paprika/script')
    end
  end
end
