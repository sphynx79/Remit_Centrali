#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

require 'rufus-scheduler'
require 'logger'
require 'open3'
require 'pastel'

$logger = Logger.new(STDOUT)
$logger.level = Logger::DEBUG
$pastel = Pastel.new
$logger.formatter = proc do |severity, datetime, _progname, msg|
  string = "#{datetime.strftime('%d-%m-%Y %X')} --[#{severity}]-- : #{msg}\n"
  case severity
  when 'DEBUG'
    $pastel.cyan.bold(string)
  when 'WARN'
    $pastel.magenta.bold(string)
  when 'INFO'
    $pastel.green.bold(string)
  when 'ERROR'
    $pastel.red.bold(string)
  when 'FATAL'
    $pastel.yellow.bold(string)
  else
    $pastel.blue(string)
  end
end
# $logger.level = Logger::WARN
# STDOUT.sync = true
# STDERR.sync = true

ENV['TZ'] = 'UTC-2'

class Handler
  attr_reader :action

  def initialize(action: nil)
    @action = action
  end

  def call(job)
    # $logger.info "#{job} at #{Time.now}"
    start_task(job)
  rescue Rufus::Scheduler::TimeoutError
    $logger.warn 'Sono andato in Timeout'
  end

  def start_task(job)
    $logger.info "Start task #{action}:"
    cmd = "#{RbConfig.ruby} Remit.rb --mail --interface=scheduler --log=info --enviroment=production #{action} "
    stdout, stderr, wait_thr = Open3.capture3(cmd)

    print stdout.strip.to_s if !stdout.nil? && (stdout != '')
    if wait_thr.exitstatus != 0
      $logger.fatal "Task #{job.tags[0]} finito con un errore imprevisto"
      return
    end
    $logger.info "Task #{job.tags[0]} finito corretamente"
  end
end

# @todo diminuire la frequenza di rufus-scheduler
scheduler = Rufus::Scheduler.new(frequency: '3m')

def scheduler.on_error(job, error)
  $logger.warn("intercepted error in #{job.id}: #{error.message}")
   end

task = Handler.new(action: 'rss')

scheduler.every('5m', task, timeout: '5m', tag: 'Download Rss')

$logger.info 'Start Scheduler'

scheduler.join

