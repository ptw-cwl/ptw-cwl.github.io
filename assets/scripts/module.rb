require 'rake'

def run(taskName)
  Rake::Task[taskName].invoke
end