#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

class InsertDb
  extend LightService::Action
  expects :remits, :db, :anagrafica

  executed do |ctx|
    logger.debug('Inserisco remit a DB')
    collection = ctx.db.collection(collection: RemitCentrali::Config.database.collection)
    bulk_up = []
    etso_no_censiti = Set[]
    ctx.remits.each do |remit|
      etso = remit[:etso]
      anagrafica_unita = ctx.anagrafica.lazy.select { |f| f['etso'] == etso }.first
      if anagrafica_unita.nil?
        logger.warn("Non ho trovato l'#{etso} in anagrafica, remit non inserita a DB")
        etso_no_censiti << etso
      else
        event_status = remit[:event_status] != 'Dismissed' ? 'Active' : 'Dismissed'

        doc = { msg_id: remit[:msg_id],
                event_status: event_status,
                market_participant: remit[:market_participant],
                unavailability_type: remit[:unavailability_type],
                etso: etso,
                zona: anagrafica_unita["zona"],
                tipo: anagrafica_unita["tipo"],
                fuel_type: remit[:fuel_type],
                install_capacity: remit[:install_capacity],
                available_capacity: remit[:available_capacity],
                unaviable_capacity: remit[:unaviable_capacity],
                unavailability_reason: remit[:unavailability_reason],
                dt_upd: remit[:dt_upd],
                dt_start: remit[:dt_start],
                dt_end: remit[:dt_end] }
        bulk_up << { update_one: { filter: { msg_id: remit[:msg_id] }, update: doc, upsert: true, bypass_document_validation: true } }
      end
    end
    result = collection.bulk_write(bulk_up)
    logger.debug("Inserito #{result.upserted_count} doc")
    logger.debug("Modificato #{result.modified_count} doc")
    send_mail(etso_no_censiti) unless etso_no_censiti.empty?
  end

  def self.send_mail(etso_no_censiti)
    msg = "Non sono state inserite le remit per i seguenti ETSO in quanto non censiti in anagrafica:\n"
    subject = 'Remit: unità non censite in anagrafica'
    etso_no_censiti.each { |etso| msg += "#{etso}\n" }
    RemitCentrali::Mail.call(subject, msg)
  end
end
