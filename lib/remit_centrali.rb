#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

$LOAD_PATH.unshift __dir__

module RemitCentrali
  autoload :Log,            'remit_centrali/log'
  autoload :Config,         'remit_centrali/config'
  autoload :Initialization, 'remit_centrali/initialization'
  autoload :Application,    'remit_centrali/application'
  autoload :BaseController, 'remit_centrali/base_controller'
  autoload :BaseModel,      'remit_centrali/base_model'
end
