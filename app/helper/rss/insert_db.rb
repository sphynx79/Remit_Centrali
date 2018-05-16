#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

class InsertDb
  extend LightService::Action
  expects :remits, :db

  executed do |ctx|
    logger.debug('Inserisco le remit a DB')
    collection = ctx.db.collection(collection: RemitCentrali::Config.database.collection)
    update = 0
    insert = 0
    ctx.remits.each do |remit|
      result = collection.update_one({ msg_id: remit[:msg_id] }, remit, upsert: true)
      if !result.upserted_count.zero?
        insert += 1
      elsif !result.modified_count.zero?
        update += 1
      end
    end
    logger.debug("Aggiunto #{insert} doc a DB") unless insert.zero?
    logger.debug("Aggiornato #{update} doc a DB") unless update.zero?
    logger.debug('Nessuna remit inserita a DB') if update.zero? && insert.zero?
  end
end
