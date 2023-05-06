module Paprika
  extend Rake::DSL

  namespace :bundle do
    desc 'update gems'
    task :update do
      sh 'bundle update --jobs 4 --retry 3'
    end

    desc 'check gems'
    task :check do
      exit 1 unless Environment.gem_fresh?
    end
  end
end
