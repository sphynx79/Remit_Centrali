#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

require 'net/http'
require 'ox'
require 'mongo'
require 'light-service'
require 'settingslogic'
require 'pastel'
require 'ap'
require 'pry'

APP_ROOT    = Pathname.new(File.expand_path('.', __dir__))
APP_NAME    = APP_ROOT.basename.to_s
APP_VERSION = '1'
CONFIG = File.join(__dir__, 'config.yml')
LOG_LEVEL = 'INFO'
ENV['APP_ENV'] = 'development'
# ENV['APP_ENV'] = 'production'
Dir[File.join(APP_ROOT, 'actions', '*.rb')].each { |file| require file }

LightService::Configuration.logger = if ENV['APP_ENV'] == 'development'
                                       Logger.new(STDOUT)
                                     else
                                       Logger.new('NUL')
                                     end

class Config < Settingslogic
  source "#{APP_ROOT}/config/config.yml"
  namespace ENV['APP_ENV']
end

module Amper
  class RemitCentrali
    extend LightService::Organizer

    def self.call
      result = with({}).reduce(
        [
          LogInit,
          SiteConnection,
          ParseFeed,
          CheckLastUpd,
          ConnectDb,
          InsertDb
          # iterate(:links, [ClickDownload, SalvaFile]),
        ]
      )
      if result.failure?
        result.log.error result.message
      elsif !result.message.empty?
        result.log.info result.message
      else
        result.log.info 'File scaricati corretamente'
      end
    rescue StandardError => e
      puts '#' * 90
      puts e.message
      puts '#' * 90
      e.backtrace[0..10].each { |x| puts x }
    end
  end
end

Amper::RemitCentrali.call
