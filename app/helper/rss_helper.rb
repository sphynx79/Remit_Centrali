#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

Dir.glob(__dir__ + '/rss/' + '*.rb', &method(:require))

module RssHelper
  extend LightService::Organizer
  def self.call
    result = with({}).reduce(
      [
        SiteConnection,
        ParseFeed,
        # CheckLastUpd,
        ConnectDb,
        InsertDb
        # iterate(:links, [ClickDownload, SalvaFile]),
      ]
    )
    if result.failure?
      logger.error result.message
    elsif !result.message.empty?
      logger.info result.message
    else
      logger.info 'File scaricati corretamente'
    end
  rescue StandardError => e
    logger.fatal '#' * 90 + "\n" + e.message + "\n" + '#' * 90
    e.backtrace[0..20].each { |x| logger.fatal x if x.include? APP_NAME }
  end
end
