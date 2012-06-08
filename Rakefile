
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
  url      'https://github.com/dseifert/hash-proxy'
  depend_on 'bones', :development => true
  depend_on 'bones-rspec', :development => true
  depend_on 'bones-git', :development => true
  depend_on 'bones-yard', :development => true
  depend_on 'redcarpet', :development => true

  yard.exclude ['version.txt']
}

require 'bones/plugins/rspec'
require 'bones/plugins/git'
require 'bones/plugins/yard'
