#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

Dir.glob(__dir__ + '/share/' + '*.rb', &method(:require))
Dir.glob(__dir__ + '/csv/' + '*.rb', &method(:require))

module CsvHelper
  extend LightService::Organizer
  def self.call(env)
    result = with({}).reduce(
      [
        ReadCsv,
        ConnectDb,
        GetCollection,
        GetAnagrafica,
        iterate(:remits, [
          SplitInDayAndHour,
          CheckLastHour,
          CheckLastDay,
          CheckLastDoc,
          InsertDocDb,
        ]),
        UpdateLastRemitCollection,
        GetCollectionLast,
        UpdateZonaHourlyCollection,
        UpdateTecnologiaHourlyCollection,
        UpdateZonaDailyCollection,
        UpdateTecnologiaDailyCollection,
      ]
    )
    if result.failure?
      logger.error result.message
    elsif result.message
      logger.info result.message
    else
      logger.info 'File csv letto corretamente'
    end
  rescue StandardError => e
    msg = e.message + "\n"
    e.backtrace.each do |x|
      # msg += x + "\n" if x.include? APP_NAME
      msg += x + "\n"
    end
    logger.fatal msg
    RemitCentrali::Mail.call('Errore imprevisto nella lettura CSV', msg) if env[:global_options][:mail]
    exit! 1
  end
end

