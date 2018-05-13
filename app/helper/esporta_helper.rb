#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

Dir.glob(__dir__ + '/esporta/' + '*.rb', &method(:require))

module EsportaHelper
  extend LightService::Organizer
  def self.call(start_date, end_date, type)
    result = with(start_date: start_date, end_date: end_date, type: type).reduce(
      [
        ConnectDb,
        FetchRemit,
        GetAnagrafica,
        SetFields,
        SplitRemits,
        ScriviCsv
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
