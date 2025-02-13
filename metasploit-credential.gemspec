$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'metasploit/credential/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'metasploit-credential'
  s.version     = Metasploit::Credential::GEM_VERSION
  s.authors     = ['Luke Imhoff', 'Trevor Rosen']
  s.email       = ['luke_imhoff@rapid7.com', 'trevor_rosen@rapid7.com']
  s.homepage    = 'https://github.com/rapid7/metasploit-credential'
  s.license     = 'BSD-3-clause'
  s.summary     = 'Credential models for metasploit-framework and Metasploit Pro'
  s.description = 'The Metasploit::Credential namespace and its ActiveRecord::Base subclasses'

  s.files = Dir['{app,config,db,lib,spec}/**/*'] + ['CONTRIBUTING.md', 'LICENSE', 'Rakefile', 'README.md']
  s.test_files = s.files.grep(/spec/)

  # patching inverse association in Mdm models.
  s.add_runtime_dependency 'metasploit-concern', '~> 0.1.0'
  # Various Metasploit::Credential records have associations to Mdm records
  s.add_runtime_dependency 'metasploit_data_models', '~> 0.19.4'
  # Metasploit::Model::Search
  s.add_runtime_dependency 'metasploit-model','~> 0.26.1'
  # Metasploit::Credential::NTLMHash helper methods
  s.add_runtime_dependency 'rubyntlm'
  # Required for supporting the en masse importation of SSH Keys
  s.add_runtime_dependency 'rubyzip', '~> 1.1'

  if RUBY_PLATFORM =~ /java/
    s.add_runtime_dependency 'jdbc-postgres'
    s.add_runtime_dependency 'activerecord-jdbcpostgresql-adapter'

    s.platform = Gem::Platform::JAVA
  else
    s.add_runtime_dependency 'pg'

    s.platform = Gem::Platform::RUBY
  end
end
