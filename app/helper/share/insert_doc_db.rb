#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

class InsertDocDb
  extend LightService::Action
  expects :remit, :collection, :anagrafica

  executed do |ctx|
    logger.debug("Inserisco remit a DB #{ctx.remit[:msg_id]}")
    etso_no_censiti = Set[]
    etso = ctx.remit[:etso]
    anagrafica_unita = ctx.anagrafica.lazy.select { |f| f['etso'] == etso }.first
    if anagrafica_unita.nil?
      logger.warn("Non ho trovato l'#{etso} in anagrafica, remit non inserita a DB")
      etso_no_censiti << etso
    else
      event_status = ctx.remit[:event_status] != 'Dismissed' ? 'Active' : 'Dismissed'

      doc = {msg_id: ctx.remit[:msg_id],
             event_status: event_status,
             market_participant: ctx.remit[:market_participant],
             unavailability_type: ctx.remit[:unavailability_type],
             etso: etso,
             zona: anagrafica_unita['zona'],
             tipo: anagrafica_unita['tipo'],
             fuel_type: ctx.remit[:fuel_type],
             install_capacity: ctx.remit[:install_capacity],
             available_capacity: ctx.remit[:available_capacity],
             unaviable_capacity: ctx.remit[:unaviable_capacity],
             unavailability_reason: ctx.remit[:unavailability_reason],
             dt_upd: ctx.remit[:dt_upd],
             dt_start: ctx.remit[:dt_start],
             dt_end: ctx.remit[:dt_end],
             is_last: ctx.remit[:is_last],
             days: ctx.remit[:days]
      }
              
      ctx.collection.update_one({msg_id: ctx.remit[:msg_id]}, {"$set": doc}, {upsert: true, bypass_document_validation: true})
      # bulk_up << {update_one: {filter: {msg_id: remit[:msg_id]}, update: doc, upsert: true, bypass_document_validation: true}}
    end
    # result = ctx.collection.bulk_write(bulk_up)
    # logger.debug("Inserito #{result.upserted_count} doc")
    # logger.debug("Modificato #{result.modified_count} doc")
    # send_mail(etso_no_censiti) unless etso_no_censiti.empty?
  end

  def self.send_mail(etso_no_censiti)
    msg = "Non sono state inserite le remit per i seguenti ETSO in quanto non censiti in anagrafica:\n"
    subject = 'Remit: unità non censite in anagrafica'
    etso_no_censiti.each { |etso| msg += "#{etso}\n" }
    RemitCentrali::Mail.call(subject, msg)
  end
end

