
begin
  require 'bones'
rescue LoadError
  abort '### Please install the "bones" gem ###'
end

task :default => 'test:run'
task 'gem:release' => 'test:run'

Bones {
  name     'hash-proxy'
  authors  'Douglas A. Seifert'
  email    'doug@dseifert.net'
  url      'https://github.com/dseifert/hash-proxy'
  depend_on 'bones', :development => true
  depend_on 'bones-rspec', :development => true
  depend_on 'bones-git', :development => true
}

require 'bones/plugins/rspec'
require 'bones/plugins/git'
