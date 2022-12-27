
begin
  require 'bones'
rescue LoadError
  abort '### Please install the "bones" gem by doing a "bundle install" ###'
end

task :default => 'spec:run'
task 'gem:release' => 'spec:run'

Bones {
  name     'hash-proxy'
  authors  'Douglas A. Seifert'
  email    'doug@dseifert.net'
  url      'https://github.com/seifertd/hash-proxy'
  license  'MIT'

  yard.exclude ['version.txt']
}

require 'bones/plugins/rspec'
require 'bones/plugins/git'
require 'bones/plugins/yard'
