#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

Dir.glob(__dir__ + '/rss/' + '*.rb', &method(:require))

module RssHelper
  extend LightService::Organizer
  def self.call(env)
    result = with({}).reduce(
      [
        SiteConnection,
        ParseFeed,
        CheckLastUpd,
        ConnectDb,
        GetAnagrafica,
        InsertDb
      ]
    )
    if result.failure?
      logger.error result.message
    elsif !result.message.empty?
      logger.info result.message
    else
      logger.info 'Feed RSS scaricati corretamente'
    end
  rescue StandardError => e
    msg = e.message + "\n"
    e.backtrace.each do |x|
      msg += x + "\n" if x.include? APP_NAME
    end
    logger.fatal msg
    RemitCentrali::Mail.call('Errore imprevisto nello scaricamento feed RSS', msg) if env[:global_options][:mail]
    exit! 1
  end
end
