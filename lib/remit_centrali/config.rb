#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

module RemitCentrali
  class Config < Settingslogic
    source File.join(__dir__, '../../config/config.yml')
    namespace ENV['APP_ENV']
  end
end
