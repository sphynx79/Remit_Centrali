#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

$LOAD_PATH.unshift '.'

require 'rubygems'
require 'bundler/setup'
require 'bootsnap'
Bootsnap.setup(
  cache_dir:            './cache',
  development_mode:     'development',
  load_path_cache:      true,
  autoload_paths_cache: true,
  disable_trace:        true,
  compile_cache_iseq:   true,
  compile_cache_yaml:   true
)

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
require 'oj'

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

  desc 'Log level [debug, info, warn, error, fatal]'
  default_value 'debug'
  flag %i[l log], required: false

  desc 'Enviroment da usare [production, development]'
  default_value 'development'
  flag %i[e enviroment], required: false, must_match: %w[production development]

  desc 'Abilita email in caso di errore imprevisto'
  default_value false
  switch :mail

  desc 'Interfaccia da usare [cli, scheduler]'
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

  desc 'Esporta in csv'
  long_desc %(Esegue una esportazione delle remit centrali dal db)
  command :esporta do |c|
    c.desc 'tipo di esportazione (dismissed, active)'
    c.flag %i[t type], required: false, default_value: ['active'], type: Array

    c.desc 'data di inizio'
    c.flag %i[sd start_date], required: false, type: String

    c.desc 'data di fine'
    c.flag %i[ed end_date], required: false, type: String

    c.action do
      RemitCentrali::Application.call(@env)
    end
  end

  pre do |global, command, options|
    init_log(global[:log])
    set_env(command, global, options)
    if command.name == :esporta
      check_export_date(options[:sd], options[:ed])
      # options[:type] = check_export_type(options[:type])
    end
    RemitCentrali::Initialization.call
    true
  end

  def set_env(command, global, options)
    LightService::Configuration.logger = Logger.new('NUL')
    if global[:enviroment] == 'development'
      # LightService::Configuration.logger = Logger.new(STDOUT)
      ENV['GLI_DEBUG'] = 'true'
      require 'pry'
      require 'ap'
    else
      # LightService::Configuration.logger = Logger.new('NUL')
      ENV['GLI_DEBUG'] = 'false'
    end
    ENV['APP_ENV'] = global[:enviroment]
    action = 'call'
    controller = command.name.to_s
    @env = { controller: controller,
             action: action,
             command_options: options,
             global_options: global }
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
        pastel.cyan.bold(string)
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

  def check_export_date(start_date, end_date)
    if start_date.nil? && end_date.nil?
      p 'Devi inserire una start date nella forma --sd dd/mm/yyyy'
      p 'Devi inserire una end date nella forma --ed dd/mm/yyyy'
      p 'Es: ruby Remit.rb esporta --sd 21/11/2016 --ed 23/11/2016'
      exit!
    end
    if !start_date.nil? && !start_date.match(%r{^\d{2}\/\d{2}\/\d{4}$})
      p 'Devi inserire una start date nella forma --sd dd/mm/yyyy'
      p 'Es: ruby Remit.rb esporta --sd 21/11/2016 --ed 23/11/2016'
      exit!
    end
    if !end_date.nil? && !end_date.match(%r{^\d{2}\/\d{2}\/\d{4}$})
      p 'Devi inserire una end date nella forma --ed dd/mm/yyyy'
      p 'Es: ruby Remit.rb esporta --sd 21/11/2016 --ed 23/11/2016'
      exit!
    end
    if start_date.nil? && !end_date.nil?
      p 'Hai inserito una data di fine ma non di inizio'
      exit!
    end
    if end_date.nil? && !start_date.nil?
      p 'Hai inserito una data di inizio ma non di fine'
      exit!
    end
    if Date.parse(start_date) > Date.parse(end_date)
      p 'Hai inserito una data di inizio maggiore della data di fine'
      exit!
    end
  end

  # Controllo se lo sto lanciandi come programma
  # oppure il file e' stato usato come require
  exit run(ARGV) if $PROGRAM_NAME == __FILE__
end
