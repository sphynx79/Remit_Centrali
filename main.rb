#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

$LOAD_PATH.unshift '.'

require 'active_support/core_ext/string/inflections'
require 'gli'
require 'lib/remit_centrali'
require 'light-service'
require 'settingslogic'
require 'mongo'
require 'pastel'
require 'logger'
require 'net/http'
require 'ox'

APP_ROOT = Pathname.new(File.expand_path('.', __dir__))
APP_NAME = APP_ROOT.parent.basename.to_s
APP_VERSION = '1'
CONFIG = File.join(__dir__, 'config.yml')

module RemitCentrali
  include GLI::App
  extend self

  program_desc 'Programma per scaricare la remit delle centrali italiane'
  version APP_VERSION
  subcommand_option_handling :normal
  arguments :strict
  sort_help :manually
  wrap_help_text :one_line

  # desc 'Setto se lanciarlo in verbose mode'
  # switch %i[v verbose]
  #
  desc 'Log level [debug, info, warn, error, fatal]'
  default_value 'info'
  flag %i[l log], required: false

  desc 'Enviroment da usare [production, development]'
  default_value 'development'
  flag %i[e enviroment], required: false, must_match: %w[production development]

  desc 'Interfaccia da usare [gui, cli, scheduler]'
  default_value 'cli'
  flag %i[i interface], required: false

  desc 'Scarica feed rss remit'
  long_desc %(Scarica da internet attraverso feed rss le remit delle centrali e le carica a db)
  command :rss do |c|
    c.action do
      RemitCentrali::Application.call(@env)
    end
  end

  desc 'Scarica csv remit'
  long_desc %(Scarica da internet il file csv di tutte le remit e le carica a db)
  command :csv do |c|
    c.action do
      RemitCentrali::Application.call(@env)
    end
  end

  pre do |global, command, options|
    init_log(global[:log])
    set_env(command, global, options)
    RemitCentrali::Initialization.call
    true
  end

  def set_env(command, global, options)
    if global[:enviroment] == 'development'
      LightService::Configuration.logger = Logger.new(STDOUT)
      ENV['GLI_DEBUG'] = 'true'
      require 'pry'
      require 'ap'
    else
      LightService::Configuration.logger = Logger.new('NUL')
      ENV['GLI_DEBUG'] = 'false'
    end
    ENV['APP_ENV'] = global[:enviroment]
    action = 'call'
    controller = command.name.to_s
    @env = { controller: controller,
             action: action,
             command_options: options }
  end

  def init_log(level)
    # Log.logger = Logger.new( 'logfile.log')
    Log.level = level.upcase
    pastel = Pastel.new
    Log.formatter = proc do |severity, datetime, _progname, msg|
      string = if severity != 'FATAL'
                 "#{datetime.strftime('%d-%m-%Y %X')} --[#{severity}]-- : #{msg}\n"
               else
                 "#{msg}\n"
               end

      case severity
      when 'DEBUG'
        string
      when 'WARN'
        pastel.magenta.bold(string)
      when 'INFO'
        pastel.green.bold(string)
      when 'ERROR'
        pastel.red.bold(string)
      when 'FATAL'
        pastel.yellow.bold(string)
      else
        pastel.blue(string)
      end
    end
    Object.send :include, Log
  end

  # Controllo se lo sto lanciandi come programma
  # oppure il file e' stato usato come require
  exit run(ARGV) if $PROGRAM_NAME == __FILE__
end
