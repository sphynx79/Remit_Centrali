#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

Dir.glob(__dir__ + '/share/' + '*.rb', &method(:require))
Dir.glob(__dir__ + '/xml/' + '*.rb', &method(:require))

module XmlHelper
  extend LightService::Organizer
  def self.call(env)
    result = with({has_new_remit: false}).reduce(
      [
        GetNewXml,
        GetLastXml,
        ParseNewXml,
        ParseLastXml,
        CheckDiff,
        reduce_if(-> (ctx) { !ctx.remits.empty? }, [
          WriteXml,
          ConnectDb,
          GetCollection,
          GetAnagrafica,
          iterate(:remits, [
            RemitExist,
            reduce_if(-> (ctx) { !ctx.remit_exist }, [
              SplitInDayAndHour,
              CheckLastHour,
              CheckLastDay,
              CheckLastDoc,
              InsertDocDb,
            ]),
          ]),
          reduce_if(-> (ctx) { ctx.has_new_remit }, [
            GetCollectionLast,
            UpdateLastRemitCollection,
            UpdateZonaHourlyCollection,
            UpdateTecnologiaHourlyCollection,
            UpdateZonaDailyCollection,
            UpdateTecnologiaDailyCollection,
          ]),
        ]),
      ]
    )
    if result.failure?
      logger.error result.message
    elsif result.message && !result.message.empty?
      logger.info result.message
    else
      logger.info 'File xml letto corretamente'
    end
  rescue StandardError => e
    # eliminare ultimo file scaricato
    last_file_xml = Dir.glob("#{APP_ROOT}/#{RemitCentrali::Config.path.download}*.xml").max_by {|f|  File.stat(f).mtime}
    FileUtils.rm_f(last_file_xml)
    msg = e.message + "\n"
    e.backtrace.each do |x|
      # msg += x + "\n" if x.include? APP_NAME
      msg += x + "\n"
    end
    logger.fatal msg
    RemitCentrali::Mail.call('Errore imprevisto nella lettura XML', msg) if env[:global_options][:mail]
    exit! 1
  end
end

