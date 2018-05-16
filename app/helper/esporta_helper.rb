#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

Dir.glob(__dir__ + '/esporta/' + '*.rb', &method(:require))

module EsportaHelper
  extend LightService::Organizer
  def self.call(env)
    start_date = env[:command_options][:start_date]
    end_date   = env[:command_options][:end_date]
    type       = env[:command_options][:type]
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
      logger.info 'Esportazione avvenuta con successo'
    end
  rescue StandardError => e
    msg = e.message + "\n"
    e.backtrace.each do |x|
      msg += x + "\n" if x.include? APP_NAME
    end
    logger.fatal msg
    RemitCentrali::Mail.call('Errore imprevisto esportazione CSV', msg) if env[:global_options][:mail]
    exit! 1
  end
end
