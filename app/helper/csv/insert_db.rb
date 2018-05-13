#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

class InsertDb
  extend LightService::Action
  expects :remits, :db

  executed do |ctx|
    logger.debug('Inserisco remit a DB')
    collection = ctx.db.collection(collection: RemitCentrali::Config.database.collection)
    bulk_up = []
    ctx.remits.each do |remit|
      event_status = remit[:event_status] != 'Dismissed' ? 'Active' : 'Dismissed'

      doc = { msg_id: remit[:msg_id],
              event_status: event_status,
              market_participant: remit[:market_participant],
              unavailability_type: remit[:unavailability_type],
              etso: remit[:etso],
              zona: remit[:zona],
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
    result = collection.bulk_write(bulk_up)
    logger.debug("Inserito #{result.upserted_count} doc")
    logger.debug("Modificato #{result.modified_count} doc")
  end
end
