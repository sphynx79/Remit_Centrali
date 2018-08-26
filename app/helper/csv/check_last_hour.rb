#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

class CheckLastHour
  extend LightService::Action
  expects :remit, :collection
  promises :days_change

  executed do |ctx|
    logger.debug("Controlla se ho già una versione precedente msg_id: #{ctx.remit[:msg_id]}")
    ctx.days_change = []
    event_status = ctx.remit[:event_status] != 'Dismissed' ? 'Active' : 'Dismissed'
    etso         = ctx.remit[:etso]
    bulk_up      = []

    if event_status == 'Active'
      ctx.remit[:days].each_with_index do |day, _index|
        data_day = day[:data_day]

        # cerca se c'e almeno un doc con etso dt_flusso
        query_etso_giorno_result = ctx.collection.find("etso": etso, event_status: 'Active', last: 1, 'days' => { '$elemMatch' => { data_day: data_day } }).entries
        
        # se non trova nulla va al prossimo giorno
        next if query_etso_giorno_result.empty?

        # scorro le ore del mio giorno
        day[:hours].each do |hour, _value|
          old_index_hour, old_index_dt_flusso, old_id = this_hour_last_exist(query_etso_giorno_result, data_day, hour)
          next unless old_index_hour
          bulk_up << { update_one: { filter: { _id: old_id }, 
                                     update: { '$set': { "days.#{old_index_dt_flusso}.hours.#{old_index_hour}.last": 0 } }, 
                                     upsert: true, 
                                     bypass_document_validation: true 
          }}
          ctx.days_change << {id: old_id, index_day: old_index_dt_flusso }
          # old_doc.update_one('$set': {"days.#{old_index_dt_flusso}.hours.#{old_index_hour}.last": 0} )
        end
        ctx.collection.bulk_write(bulk_up, write: { w: 0 })
        ctx.days_change.uniq!{|k| [k[:id], k[:index_day]]} unless ctx.days_change.empty?
      end
      

    end
    
  end

  #
  # Mi scorre tutti i documenti che ha trovato per etso e giorno
  # e cerca se c'è l'ora che mi interessa con last = 1
  # se non trova nulla restiruisce false altrimenti restiruisce l'ora index della data
  # di flusso e l'id del documento che ha trovato
  #
  # @param query_etso_giorno [Array<BSON::Document>] array dei documenti che ha trovato
  # @param data_day [Date] data di flusso da cercare
  # @param hour [Fixnum] ora da cercare
  #
  # @return  [Array<BSON::Document, Fixnum, BSON::ObjectId>, False]
  #
  def self.this_hour_last_exist(query_etso_giorno_result, data_day, hour)
    query_etso_giorno_result.each do |doc|
      index_data_day = search_index_dt_flusso(doc, data_day)
      day = doc.dig('days', index_data_day)
      index_hour = search_index_hour(day, hour[:data_hour]) 
      next if index_hour.nil?
      return index_hour, index_data_day, doc['_id'] if day.dig('hours')[index_hour][:last] == 1
    end
    false
  end

  #
  # Cerca nei giorni del risultato della query
  # l'index dell'array in cui si trova la data di flusso
  #
  # @param doc [BSON::Document]
  # @param data_day [Date]
  #
  # @return [Fixnum]
  #
  def self.search_index_dt_flusso(doc, data_day)
    index = nil
    doc.dig('days').each_with_index do |k, i|
      if data_day == k['data_day'].to_date
        index = i
        break
      end
    end
    index
  end

   #
  # Cerca in hours del risultato del giorno che ha trovato
  # l'index dell'array in cui si trova la ora
  #
  # @param doc [BSON::Document]
  # @param data_day [Date]
  #
  # @return [Fixnum]
  #
  def self.search_index_hour(day, hour)
    index = nil
    day.dig('hours').each_with_index do |k, i|
      if hour.to_time.utc == k["data_hour"]
        index = i
        break
      end
    end
    index
  end

  private_class_method :this_hour_last_exist, :search_index_dt_flusso, :search_index_hour
end
