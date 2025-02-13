
#
# Gems
#
# gems must load explicitly any gem declared in gemspec
# @see https://github.com/bundler/bundler/issues/2018#issuecomment-6819359
#
#

require 'metasploit/concern'
require 'metasploit_data_models'
require 'metasploit/model'
require 'zip'

#
# Project
#

# Only include the Rails engine when using Rails.  This is for compatibility with metasploit-framework.
if defined? Rails
  require 'metasploit/credential/engine'
end

# Shared namespace for metasploit gems; used in {https://github.com/rapid7/metasploit-credential metasploit-credential},
# {https://github.com/rapid7/metasploit-framework metasploit-framework}, and
# {https://github.com/rapid7/metasploit-model metasploit-model}
module Metasploit
  # The namespace for this gem.
  module Credential
    extend ActiveSupport::Autoload

    autoload :Creation
    autoload :EntityRelationshipDiagram
    autoload :Exporter
    autoload :Importer
    autoload :Migrator
    autoload :Origin
    autoload :Text

    # The prefix for all `ActiveRecord::Base#table_name`s for `ActiveRecord::Base` subclasses under this namespace.
    #
    # @return [String] `'metasploit_credential_'`
    def self.table_name_prefix
      'metasploit_credential_'
    end
  end
end

